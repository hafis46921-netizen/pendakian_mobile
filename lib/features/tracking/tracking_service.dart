import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api_config.dart';
import 'tracking_models.dart';
import 'tracking_queue.dart';

class TrackingException implements Exception {
  final String message;
  final bool locationServiceDisabled;
  final bool permissionDeniedForever;

  TrackingException(
    this.message, {
    this.locationServiceDisabled = false,
    this.permissionDeniedForever = false,
  });

  @override
  String toString() => message;
}

/// Service global yang mengelola GPS, antrian offline, dan sinkronisasi
/// ke backend. Tetap berjalan walau halaman tracking ditutup.
class TrackingService extends ChangeNotifier {
  TrackingService._();

  static final TrackingService instance = TrackingService._();

  static const _sessionKey = 'tracking_session_id';
  static const _bookingKey = 'tracking_booking_id';
  static const _pendingStopKey = 'tracking_pending_stop';

  final TrackingQueue _queue = TrackingQueue();

  TrackingConfig config = const TrackingConfig();

  bool _initialized = false;
  bool isTracking = false;
  bool isStarting = false;
  bool isSyncing = false;
  int? sessionId;
  int? bookingId;
  String? error;
  DateTime? lastSyncAt;
  int pendingCount = 0;
  TrackingFix? lastFix;
  List<LatLng> trail = [];
  Map<String, dynamic>? activeBooking;
  TrackingSessionInfo? sessionInfo;

  StreamSubscription<Position>? _positionSub;
  Timer? _flushTimer;
  int _sequence = 0;
  bool _flushing = false;
  int _retryDelaySeconds = 15;
  DateTime? _nextRetryAt;
  bool _pendingStop = false;
  bool _draining = false;
  final List<TrackingFix> _pendingFixes = [];

  LatLng? get currentPoint => lastFix?.latLng;

  LatLng? get basecampPoint {
    final basecamp = activeBooking?['basecamp'];
    if (basecamp is! Map) return null;
    final lat = (basecamp['latitude'] as num?)?.toDouble();
    final lng = (basecamp['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  double? get distanceFromBasecampM {
    final basecamp = basecampPoint;
    final fix = lastFix;
    if (basecamp == null || fix == null) return null;
    return _distanceMeters(
      fix.latitude,
      fix.longitude,
      basecamp.latitude,
      basecamp.longitude,
    );
  }

  String? get basecampName {
    final basecamp = activeBooking?['basecamp'];
    if (basecamp is Map) return basecamp['nama']?.toString();
    return null;
  }

  String? get mountainName {
    final basecamp = activeBooking?['basecamp'];
    if (basecamp is Map && basecamp['gunung'] is Map) {
      return (basecamp['gunung'] as Map)['nama']?.toString();
    }
    return null;
  }

  bool get hasPendingPoints => pendingCount > 0;
  bool get hasActiveSession => sessionId != null && isTracking;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    sessionId = prefs.getInt(_sessionKey);
    bookingId = prefs.getInt(_bookingKey);
    _pendingStop = prefs.getBool(_pendingStopKey) ?? false;

    if (sessionId != null) {
      pendingCount = await _queue.count(sessionId);
      isTracking = true;
    } else {
      pendingCount = await _queue.count();
    }

    notifyListeners();
  }

  /// Dipanggil saat aplikasi dibuka. Melanjutkan sesi yang masih aktif
  /// tanpa menampilkan dialog izin.
  Future<void> resumeIfActive() async {
    await initialize();
    if (sessionId == null) return;

    try {
      final response = await _get('/user/tracking/active');
      final data = response['data'];
      final sessionJson = data?['session'];

      if (sessionJson is! Map || sessionJson['status'] != 'active') {
        await _clearLocalSession();
        return;
      }

      config = TrackingConfig.fromJson(
        (response['config'] as Map?)?.cast<String, dynamic>(),
      );
      sessionInfo = TrackingSessionInfo.fromJson(
        sessionJson.cast<String, dynamic>(),
      );
      activeBooking = (data?['booking'] as Map?)?.cast<String, dynamic>();
      isTracking = true;

      if (await _hasLocationPermission()) {
        _ensureStream();
        _startFlushTimer();
      }

      await loadTrail();
      notifyListeners();
      unawaited(flushNow(force: true));
    } catch (_) {
      // Diamkan; user tetap bisa membuka halaman tracking untuk memperbaiki.
    }
  }

  /// Ambil tiket aktif dan sesi tracking dari server.
  Future<Map<String, dynamic>?> refreshActive() async {
    final response = await _get('/user/tracking/active');
    config = TrackingConfig.fromJson(
      (response['config'] as Map?)?.cast<String, dynamic>(),
    );

    final data = (response['data'] as Map?)?.cast<String, dynamic>();
    final sessionJson = data?['session'];
    activeBooking = (data?['booking'] as Map?)?.cast<String, dynamic>();

    if (sessionJson is Map && sessionJson['status'] == 'active') {
      sessionInfo = TrackingSessionInfo.fromJson(
        sessionJson.cast<String, dynamic>(),
      );
      sessionId = sessionInfo!.id;
      bookingId = int.tryParse(
        activeBooking?['id']?.toString() ?? '',
      );
      isTracking = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, sessionId!);
      if (bookingId != null) {
        await prefs.setInt(_bookingKey, bookingId!);
      }

      if (await _hasLocationPermission()) {
        _ensureStream();
        _startFlushTimer();
      }

      await loadTrail();
      pendingCount = await _queue.count(sessionId);
      notifyListeners();
      unawaited(flushNow(force: true));
    } else {
      sessionId = null;
      bookingId = int.tryParse(
        activeBooking?['id']?.toString() ?? '',
      );
      sessionInfo = null;
      isTracking = false;
      await _clearLocalSession(keepBooking: true);
    }

    return data;
  }

  /// Cek izin lokasi dan ambil posisi untuk titik start.
  Future<StartCheckResult> prepareStart({
    required int bookingId,
    Map<String, dynamic>? booking,
  }) async {
    if (booking != null) {
      activeBooking = booking;
    }
    if (activeBooking == null) {
      try {
        await refreshActive();
      } catch (_) {
        // Abaikan; jarak basecamp akan dilewati.
      }
    }

    await _ensureLocationReady();

    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
    } on TimeoutException {
      throw TrackingException(
        'GPS belum mendapatkan sinyal. Coba keluar sebentar atau tunggu beberapa saat.',
      );
    }

    final basecamp = basecampPoint;
    final distance = basecamp == null
        ? null
        : _distanceMeters(
            position.latitude,
            position.longitude,
            basecamp.latitude,
            basecamp.longitude,
          );

    return StartCheckResult(
      bookingId: bookingId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      recordedAt: position.timestamp,
      distanceM: distance,
      geofenceRadiusM: config.geofenceRadiusM,
    );
  }

  /// Kirim titik start ke server lalu aktifkan GPS.
  Future<void> confirmStart(StartCheckResult check) async {
    if (isStarting || isTracking) return;

    isStarting = true;
    error = null;
    notifyListeners();

    try {
      final response = await _post('/user/tracking/start', {
        'booking_id': check.bookingId,
        'latitude': check.latitude,
        'longitude': check.longitude,
        'accuracy': check.accuracy,
        'altitude': check.altitude,
        'speed': check.speed,
        'client_uuid': 'start-${check.recordedAt.millisecondsSinceEpoch}',
        'recorded_at': check.recordedAt.toIso8601String(),
      });

      config = TrackingConfig.fromJson(
        (response['config'] as Map?)?.cast<String, dynamic>(),
      );

      final data = (response['data'] as Map?)?.cast<String, dynamic>();
      final sessionJson = data?['session'] as Map?;
      if (sessionJson == null) {
        throw TrackingException('Server tidak mengembalikan sesi tracking.');
      }

      sessionInfo = TrackingSessionInfo.fromJson(
        sessionJson.cast<String, dynamic>(),
      );
      sessionId = sessionInfo!.id;
      bookingId = check.bookingId;
      activeBooking =
          (data?['booking'] as Map?)?.cast<String, dynamic>() ?? activeBooking;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionKey, sessionId!);
      await prefs.setInt(_bookingKey, bookingId!);
      await prefs.setBool(_pendingStopKey, false);
      _pendingStop = false;

      trail = [];
      lastFix = TrackingFix(
        clientUuid: 'start-${check.recordedAt.millisecondsSinceEpoch}',
        latitude: check.latitude,
        longitude: check.longitude,
        accuracy: check.accuracy,
        altitude: check.altitude,
        speed: check.speed,
        recordedAt: check.recordedAt,
      );
      trail.add(lastFix!.latLng);

      isTracking = true;
      isStarting = false;
      _ensureStream();
      _startFlushTimer();
      notifyListeners();
    } catch (e) {
      isStarting = false;
      error = e is TrackingException ? e.message : 'Gagal memulai tracking.';
      notifyListeners();
      rethrow;
    }
  }

  /// Hentikan tracking. Jika offline, titik yang tersisa disimpan dan
  /// sesi ditutup otomatis saat sinyal kembali.
  Future<void> stopTracking() async {
    if (sessionId == null) {
      await _clearLocalSession();
      return;
    }

    await _positionSub?.cancel();
    _positionSub = null;
    _flushTimer?.cancel();
    _flushTimer = null;

    try {
      await flushNow(force: true);
      await _sendStop();
    } catch (_) {
      _pendingStop = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingStopKey, true);
      isTracking = false;
      error =
          'Tracking dihentikan di perangkat. Data terakhir akan dikirim saat sinyal kembali.';
      notifyListeners();
      // Tetap coba kirim ulang secara berkala.
      _startFlushTimer();
    }
  }

  /// Kirim semua titik yang tertunda. Aman dipanggil berulang.
  Future<void> flushNow({bool force = false}) async {
    final currentSession = sessionId;
    if (currentSession == null || _flushing) return;

    if (!force &&
        _nextRetryAt != null &&
        DateTime.now().isBefore(_nextRetryAt!)) {
      return;
    }

    _flushing = true;
    isSyncing = true;
    notifyListeners();

    try {
      while (true) {
        final rows = await _queue.pending(
          currentSession,
          limit: config.maxPointsPerBatch,
        );
        if (rows.isEmpty) break;

        final points = rows
            .map((row) => row['payload'] as Map<String, dynamic>)
            .toList();

        final response = await _post('/user/tracking/ping', {
          'session_id': currentSession,
          'points': points,
        });

        final rowIds = rows
            .map((row) => (row['row_id'] as num).toInt())
            .toList();
        await _queue.remove(rowIds);

        pendingCount = await _queue.count(currentSession);
        lastSyncAt = DateTime.now();
        _retryDelaySeconds = 15;
        _nextRetryAt = null;
        error = null;

        if (response['ended'] == true) {
          await _handleServerEnded();
          break;
        }

        if (points.length < config.maxPointsPerBatch) break;
      }

      if (_pendingStop && pendingCount == 0) {
        await _sendStop();
      }

      notifyListeners();
    } catch (e) {
      if (e is TrackingException && e.message.contains('berakhir')) {
        await _handleServerEnded();
      } else {
        error = 'Gagal mengirim lokasi. Titik disimpan dan akan dikirim ulang.';
        _nextRetryAt = DateTime.now().add(
          Duration(seconds: _retryDelaySeconds),
        );
        _retryDelaySeconds =
            math.min(_retryDelaySeconds * 2, 300);
      }
      notifyListeners();
    } finally {
      _flushing = false;
      isSyncing = false;
      notifyListeners();
    }
  }

  /// Ambil jejak dari server untuk sesi yang sedang aktif.
  Future<void> loadTrail() async {
    final currentSession = sessionId;
    if (currentSession == null) return;

    try {
      final response = await _get('/user/tracking/$currentSession');
      final data = (response['data'] as Map?)?.cast<String, dynamic>();
      final rawPoints = data?['points'];
      if (rawPoints is! List) return;

      final points = rawPoints
          .whereType<Map>()
          .map((item) => TrackingFix.fromJson(item.cast<String, dynamic>()))
          .toList();

      if (points.isEmpty) return;

      trail = points.map((point) => point.latLng).toList();
      lastFix = points.last;
      notifyListeners();
    } catch (_) {
      // Abaikan; jejak akan terisi dari titik GPS baru.
    }
  }

  Future<void> _sendStop() async {
    final currentSession = sessionId;
    if (currentSession == null) return;

    final fix = lastFix;

    await _post('/user/tracking/stop', {
      'session_id': currentSession,
      if (fix != null) ...{
        'latitude': fix.latitude,
        'longitude': fix.longitude,
        'accuracy': fix.accuracy,
        'altitude': fix.altitude,
        'speed': fix.speed,
        'client_uuid': fix.clientUuid,
        'recorded_at': fix.recordedAt.toIso8601String(),
      },
    });

    await _queue.clear(currentSession);
    await _clearLocalSession();
  }

  Future<void> _handleServerEnded() async {
    final currentSession = sessionId;
    if (currentSession != null) {
      await _queue.clear(currentSession);
    }
    await _clearLocalSession();
    error = 'Sesi tracking telah berakhir.';
    notifyListeners();
  }

  void _ensureStream() {
    if (_positionSub != null) return;

    final settings = _locationSettings();

    _positionSub =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      _onPosition,
      onError: (Object err) {
        error = 'GPS error: $err';
        notifyListeners();
      },
      cancelOnError: false,
    );
  }

  LocationSettings _locationSettings() {
    const distanceFilter = 10;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: Duration(seconds: config.pingIntervalSeconds),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'SummitGo - Tracking Pendakian',
          notificationText:
              'Lokasi Anda dibagikan ke admin basecamp selama pendakian aktif.',
          notificationIcon:
              AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true,
        ),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilter,
    );
  }

  void _onPosition(Position position) {
    final currentSession = sessionId;
    if (currentSession == null) return;

    final fix = TrackingFix(
      clientUuid:
          '$currentSession-${position.timestamp.millisecondsSinceEpoch}-${_sequence++}',
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      recordedAt: position.timestamp,
    );

    lastFix = fix;
    trail.add(fix.latLng);
    if (trail.length > 3000) {
      trail = trail.sublist(trail.length - 3000);
    }

    notifyListeners();
    unawaited(_enqueue(fix));
  }

  Future<void> _enqueue(TrackingFix fix) async {
    final currentSession = sessionId;
    if (currentSession == null) return;

    // Buffer di memori agar titik yang datang saat proses simpan masih
    // berjalan tidak hilang.
    _pendingFixes.add(fix);
    if (_draining) return;

    _draining = true;
    try {
      while (_pendingFixes.isNotEmpty) {
        final batch = List<TrackingFix>.from(_pendingFixes);
        _pendingFixes.clear();

        try {
          await _queue.enqueue(
            currentSession,
            batch.map((item) => item.toJson()).toList(),
          );
        } catch (_) {
          // Simpan kembali di memori dan coba lagi pada kesempatan berikutnya.
          _pendingFixes.insertAll(0, batch);
          break;
        }
      }

      pendingCount = await _queue.count(currentSession);
      notifyListeners();

      if (pendingCount >= config.maxPointsPerBatch) {
        unawaited(flushNow());
      }
    } finally {
      _draining = false;
    }
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      Duration(seconds: config.pingIntervalSeconds),
      (_) => unawaited(flushNow()),
    );
  }

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw TrackingException(
        'Layanan lokasi (GPS) belum aktif. Aktifkan GPS terlebih dahulu.',
        locationServiceDisabled: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw TrackingException(
        'Izin lokasi ditolak permanen. Buka pengaturan aplikasi dan izinkan akses lokasi.',
        permissionDeniedForever: true,
      );
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw TrackingException(
        'Izin lokasi diperlukan untuk memulai tracking.',
      );
    }
  }

  Future<bool> _hasLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> _clearLocalSession({bool keepBooking = false}) async {
    await _positionSub?.cancel();
    _positionSub = null;
    _flushTimer?.cancel();
    _flushTimer = null;

    sessionId = null;
    sessionInfo = null;
    isTracking = false;
    trail = [];
    lastFix = null;
    _pendingFixes.clear();
    if (!keepBooking) {
      activeBooking = null;
      bookingId = null;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    if (!keepBooking) {
      await prefs.remove(_bookingKey);
    }
    await prefs.setBool(_pendingStopKey, false);
    _pendingStop = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _headers();
    final url = Uri.parse('${ApiConfig.baseUrl}$path');

    http.Response response;
    try {
      response = await http.get(url, headers: headers);
    } catch (e) {
      throw TrackingException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }

    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    final url = Uri.parse('${ApiConfig.baseUrl}$path');

    http.Response response;
    try {
      response = await http.post(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      throw TrackingException(
        'Tidak dapat terhubung ke server. Titik akan dikirim ulang.',
      );
    }

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        body = decoded.cast<String, dynamic>();
      }
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? {};
    }

    final message = body?['message']?.toString() ??
        'Permintaan gagal (HTTP ${response.statusCode}).';

    throw TrackingException(message);
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.pow(math.sin(dLon / 2), 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
