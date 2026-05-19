// lib/core/api_config.dart

class ApiConfig {
  // Cukup ubah IP di satu baris ini saja saat kamu ganti Wi-Fi!
  static const String _host = "192.168.100.6:8000"; 
  
  // Base URL Utama untuk API
  static const String baseUrl = "http://$_host/api";
  
  // Base URL untuk memuat file gambar/storage dari Laravel
  static const String storageUrl = "http://$_host/storage";
}