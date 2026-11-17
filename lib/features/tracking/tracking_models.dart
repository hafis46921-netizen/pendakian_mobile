import 'package:latlong2/latlong.dart';

/// Konfigurasi tracking dari server.
class TrackingConfig {
  final int pingIntervalSeconds;
  final int geofenceRadiusM;
  final int maxPointsPerBatch;

  const TrackingConfig({
    this.pingIntervalSeconds = 20,
    this.geofenceRadiusM = 1000,
    this.maxPointsPerBatch = 100,
  });

  factory TrackingConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TrackingConfig();
    return TrackingConfig(
      pingIntervalSeconds:
          (json['ping_interval_seconds'] as num?)?.toInt() ?? 20,
      geofenceRadiusM: (json['geofence_radius_m'] as num?)?.toInt() ?? 1000,
      maxPointsPerBatch:
          (json['max_points_per_batch'] as num?)?.toInt() ?? 100,
    );
  }
}

/// Satu titik GPS yang siap dikirim ke backend.
class TrackingFix {
  final String clientUuid;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime recordedAt;

  TrackingFix({
    required this.clientUuid,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.altitude,
    this.speed,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() {
    return {
      'client_uuid': clientUuid,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory TrackingFix.fromJson(Map<String, dynamic> json) {
    return TrackingFix(
      clientUuid: json['client_uuid']?.toString() ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      recordedAt: DateTime.tryParse(json['recorded_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Ringkasan sesi tracking yang dikembalikan server.
class TrackingSessionInfo {
  final int id;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double? lastLatitude;
  final double? lastLongitude;
  final double? lastAccuracy;
  final double? lastAltitude;
  final double? lastSpeed;
  final int? lastBattery;
  final DateTime? lastRecordedAt;
  final int? startDistanceM;

  const TrackingSessionInfo({
    required this.id,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.lastLatitude,
    this.lastLongitude,
    this.lastAccuracy,
    this.lastAltitude,
    this.lastSpeed,
    this.lastBattery,
    this.lastRecordedAt,
    this.startDistanceM,
  });

  bool get isActive => status == 'active';

  factory TrackingSessionInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return TrackingSessionInfo(
      id: (json['id'] as num).toInt(),
      status: json['status']?.toString() ?? 'ended',
      startedAt: parseDate(json['started_at']),
      endedAt: parseDate(json['ended_at']),
      lastLatitude: (json['last_latitude'] as num?)?.toDouble(),
      lastLongitude: (json['last_longitude'] as num?)?.toDouble(),
      lastAccuracy: (json['last_accuracy'] as num?)?.toDouble(),
      lastAltitude: (json['last_altitude'] as num?)?.toDouble(),
      lastSpeed: (json['last_speed'] as num?)?.toDouble(),
      lastBattery: (json['last_battery'] as num?)?.toInt(),
      lastRecordedAt: parseDate(json['last_recorded_at']),
      startDistanceM: (json['start_distance_m'] as num?)?.toInt(),
    );
  }
}

/// Hasil pengecekan sebelum tracking dimulai (izin, posisi, jarak basecamp).
class StartCheckResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime recordedAt;
  final double? distanceM;
  final int geofenceRadiusM;
  final int bookingId;

  const StartCheckResult({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.geofenceRadiusM,
    required this.bookingId,
    this.accuracy,
    this.altitude,
    this.speed,
    this.distanceM,
  });

  bool get isFarFromBasecamp =>
      distanceM != null && distanceM! > geofenceRadiusM;
}
