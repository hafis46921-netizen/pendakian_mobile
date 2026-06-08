class ApiConfig {
  static const String baseUrl =
      "https://pendakian.cicd.my.id/api";

  static String get storageUrl =>
      baseUrl.replaceAll('/api', '');
} 