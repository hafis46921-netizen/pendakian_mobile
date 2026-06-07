class ApiConfig {
  static const String baseUrl =
      "http://192.168.0.105:8000/api";

  static String get storageUrl =>
      baseUrl.replaceAll('/api', '');
} 