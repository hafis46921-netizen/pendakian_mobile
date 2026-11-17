import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'tracking_service.dart';

class TrackingPage extends StatefulWidget {
  final int bookingId;
  final String? bookingLabel;
  final String? basecampLabel;

  const TrackingPage({
    super.key,
    required this.bookingId,
    this.bookingLabel,
    this.basecampLabel,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TrackingService _service = TrackingService.instance;
  final MapController _mapController = MapController();

  bool _loading = true;
  bool _starting = false;
  bool _mapReady = false;
  bool _hasCentered = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
    _refresh();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {});
    _maybeCenter();
  }

  Future<void> _refresh() async {
    try {
      await _service.initialize();
      final data = await _service.refreshActive();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });

      // Jika server tidak punya tiket aktif untuk booking ini,
      // tetap tampilkan info agar user tahu penyebabnya.
      final booking = data?['booking'];
      if (booking == null && _service.sessionId == null) {
        setState(() {
          _error =
              'Tiket ini belum divalidasi (check-in) oleh admin basecamp, atau pendakian sudah selesai.';
        });
      }

      _maybeCenter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is TrackingException ? e.message : e.toString();
      });
    }
  }

  void _maybeCenter() {
    if (!_mapReady) return;
    final point = _service.currentPoint;
    if (point == null) return;

    if (!_hasCentered) {
      _hasCentered = true;
      _mapController.move(point, 16);
    }
  }

  Future<void> _startTracking() async {
    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final check = await _service.prepareStart(
        bookingId: widget.bookingId,
        booking: _service.activeBooking,
      );

      if (!mounted) return;

      if (check.isFarFromBasecamp) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Masih Jauh dari Basecamp'),
            content: Text(
              'Anda terdeteksi sekitar ${_formatDistance(check.distanceM)} '
              'dari basecamp.\n\n'
              'Sebaiknya mulai tracking setelah tiba di basecamp. '
              'Tetap mulai sekarang?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4B7C),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Tetap Mulai',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );

        if (proceed != true) {
          setState(() => _starting = false);
          return;
        }
      }

      await _service.confirmStart(check);
      _hasCentered = false;
      _maybeCenter();
    } on TrackingException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      await _showLocationHelp(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _stopTracking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Hentikan Tracking?'),
        content: const Text(
          'Lokasi Anda tidak akan dibagikan lagi ke admin basecamp. '
          'Pendakian tetap bisa dilanjutkan, namun admin tidak bisa '
          'melihat posisi Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hentikan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _service.stopTracking();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking dihentikan.')),
    );
  }

  Future<void> _showLocationHelp(TrackingException error) async {
    if (!error.locationServiceDisabled && !error.permissionDeniedForever) {
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          error.locationServiceDisabled
              ? 'Aktifkan GPS'
              : 'Izin Lokasi Diperlukan',
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (error.locationServiceDisabled) {
                Geolocator.openLocationSettings();
              } else {
                Geolocator.openAppSettings();
              }
            },
            child: Text(
              error.locationServiceDisabled
                  ? 'Buka Pengaturan Lokasi'
                  : 'Buka Pengaturan Aplikasi',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = _service.sessionId != null && _service.isTracking;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Lacak Pendakian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2F4B7C),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : isActive
              ? _buildMapView(isDark)
              : _buildStartView(isDark),
    );
  }

  Widget _buildStartView(bool isDark) {
    final booking = _service.activeBooking;
    final basecamp = _service.basecampName ?? widget.basecampLabel;
    final gunung = _service.mountainName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F4B7C).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    size: 42,
                    color: Color(0xFF2F4B7C),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Siap Memulai Pendakian?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aktifkan tracking agar admin basecamp dapat memantau '
                  'posisi Anda selama pendakian. Lokasi hanya dibagikan '
                  'saat tracking aktif dan berhenti setelah Anda menekan '
                  'tombol hentikan atau setelah checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                if (basecamp != null || gunung != null)
                  _infoRow(
                    Icons.terrain,
                    '${gunung ?? 'Gunung'}${basecamp != null ? ' • $basecamp' : ''}',
                    isDark,
                  ),
                if (booking != null)
                  _infoRow(
                    Icons.confirmation_number_outlined,
                    booking['order_id']?.toString() ??
                        'Booking #${booking['id']}',
                    isDark,
                  ),
                if (widget.bookingLabel != null && booking == null)
                  _infoRow(
                    Icons.confirmation_number_outlined,
                    widget.bookingLabel!,
                    isDark,
                  ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _starting ? null : _startTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4B7C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _starting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                    label: Text(
                      _starting ? 'Menyiapkan GPS...' : 'Mulai Lacak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat ulang status tiket'),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Tips: aktifkan GPS dengan akurasi tinggi dan izinkan '
            'aplikasi berjalan di latar belakang agar tracking tetap '
            'berjalan saat layar mati.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(bool isDark) {
    final fix = _service.lastFix;
    final basecamp = _service.basecampPoint;
    final center = fix?.latLng ??
        basecamp ??
        const LatLng(-2.548926, 118.014863);

    final markers = <Marker>[
      if (basecamp != null)
        Marker(
          point: basecamp,
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Color(0xFF2F4B7C),
              size: 28,
            ),
          ),
        ),
      if (fix != null)
        Marker(
          point: fix.latLng,
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2F4B7C),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
            minZoom: 4,
            maxZoom: 19,
            onMapReady: () {
              setState(() => _mapReady = true);
              _maybeCenter();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.summitgo',
              maxZoom: 19,
            ),
            if (fix != null &&
                (fix.accuracy ?? 0) > 0 &&
                (fix.accuracy ?? 0) < 200)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: fix.latLng,
                    radius: fix.accuracy ?? 0,
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.10),
                    borderColor: Colors.blue.withOpacity(0.35),
                    borderStrokeWidth: 1,
                  ),
                ],
              ),
            if (_service.trail.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _service.trail,
                    strokeWidth: 4,
                    color: const Color(0xFF2F4B7C),
                    borderColor: Colors.white,
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),

        // Status atas
        Positioned(
          top: 14,
          left: 14,
          right: 70,
          child: _statusBanner(isDark),
        ),

        // Tombol recenter
        Positioned(
          top: 14,
          right: 14,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 3,
            child: IconButton(
              tooltip: 'Kembali ke posisi saya',
              icon: const Icon(Icons.my_location, color: Color(0xFF2F4B7C)),
              onPressed: () {
                final point = _service.currentPoint;
                if (point != null && _mapReady) {
                  _mapController.move(point, 16);
                  _hasCentered = true;
                }
              },
            ),
          ),
        ),

        // Panel info bawah
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _infoPanel(isDark),
        ),
      ],
    );
  }

  Widget _statusBanner(bool isDark) {
    final hasPending = _service.hasPendingPoints;
    final syncing = _service.isSyncing;

    final color = hasPending ? Colors.orange : Colors.green;
    final label = syncing
        ? 'Mengirim lokasi...'
        : hasPending
            ? 'Menunggu sinyal (${_service.pendingCount} titik)'
            : 'Tracking aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F4B7C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel(bool isDark) {
    final fix = _service.lastFix;
    final lastSeen = fix?.recordedAt;
    final accuracy = fix?.accuracy;
    final altitude = fix?.altitude;
    final speed = fix?.speed;
    final distance = _service.distanceFromBasecampM;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service.basecampName ??
                            widget.basecampLabel ??
                            'Pendakian Aktif',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2F4B7C),
                        ),
                      ),
                      if (_service.mountainName != null)
                        Text(
                          _service.mountainName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                _liveChip(),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _metric('Akurasi', accuracy == null ? '-' : '±${accuracy.toStringAsFixed(0)} m'),
                _metric(
                  'Altitude',
                  altitude == null ? '-' : '${altitude.toStringAsFixed(0)} m',
                ),
                _metric(
                  'Kecepatan',
                  speed == null ? '-' : '${speed.toStringAsFixed(1)} m/s',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _metric(
                  'Jarak basecamp',
                  distance == null ? '-' : _formatDistance(distance),
                ),
                _metric(
                  'Update terakhir',
                  lastSeen == null ? '-' : _formatTime(lastSeen),
                ),
              ],
            ),
            if (_service.hasPendingPoints) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_service.pendingCount} titik tersimpan di perangkat '
                        'dan akan dikirim saat sinyal kembali.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _stopTracking,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text(
                  'Hentikan Tracking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2F4B7C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
