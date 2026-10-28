class ApiConfig {
  static const String baseUrl =
      "http://192.168.0.7:8000/api";

  static String get storageUrl =>
      baseUrl.replaceAll('/api', '');
} 