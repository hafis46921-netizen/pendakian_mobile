// lib/features/ticket/invoice_pembayaran_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Memeriksa jika berjalan di browser
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:url_launcher/url_launcher.dart'; // Handler pembuka url universal
import '../../api_config.dart'; 

class InvoicePembayaranPage extends StatefulWidget {
  const InvoicePembayaranPage({super.key});

  @override
  State<InvoicePembayaranPage> createState() => _InvoicePembayaranPageState();
}

class _InvoicePembayaranPageState extends State<InvoicePembayaranPage> {
  MidtransSDK? _midtrans;
  bool _isMidtransReady = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi SDK Midtrans hanya jika dijalankan di Mobile native (Android/iOS)
    if (!kIsWeb) {
      _initMidtrans();
    } else {
      debugPrint("Berjalan di platform Web, melewati inisialisasi Mobile SDK.");
    }
  }

  // Inisialisasi resmi SDK Midtrans untuk platform Mobile
  Future<void> _initMidtrans() async {
    try {
      final midtrans = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: "Mid-client-V1peTMYtKp6WgMjW", 
          merchantBaseUrl: ApiConfig.baseUrl,
          language: 'id', 
        ),
      );

      midtrans.setTransactionFinishedCallback((result) {
        final String rawResult = result.toString().toLowerCase();
        debugPrint("Midtrans Transaction Response: $rawResult");

        if (rawResult.contains('settlement') || rawResult.contains('capture') || rawResult.contains('success')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pembayaran Berhasil!"), backgroundColor: Colors.green),
          );
          Navigator.pushReplacementNamed(context, '/history');
        } else if (rawResult.contains('pending')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Menunggu Pembayaran Diselesaikan"), backgroundColor: Colors.orange),
          );
          Navigator.pushReplacementNamed(context, '/history');
        } else if (rawResult.contains('cancel') || rawResult.contains('deny')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pembayaran Dibatalkan / Ditolak"), backgroundColor: Colors.red),
          );
        }
      });

      setState(() {
        _midtrans = midtrans;
        _isMidtransReady = true;
      });
    } catch (e) {
      debugPrint("Gagal menginisialisasi Midtrans Mobile SDK: $e");
      setState(() {
        _isMidtransReady = false;
      });
    }
  }
  
  // 🛠️ Gerbang Pembayaran Fleksibel (Mendukung Web & Mobile)
  Future<void> _mulaiPembayaran(String? snapToken) async {
    if (snapToken == null || snapToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token pembayaran tidak ditemukan dari server"), backgroundColor: Colors.red),
      );
      return;
    }

    // A. JIKA BERJALAN DI WEB ATAU SDK MOBILE BELUM SIAP
    if (kIsWeb || !_isMidtransReady) {
      // Membuat direct link snap payment sandbox bypass
      final String snapUrl = "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken";
      final Uri url = Uri.parse(snapUrl);
      
      debugPrint("Membuka Gerbang Pembayaran Web: $snapUrl");
      
      if (await canLaunchUrl(url)) {
        // Membuka halaman pembayaran di tab browser baru
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka browser pembayaran"), backgroundColor: Colors.red),
        );
      }
    } 
    // B. JIKA BERJALAN DI MOBILE NATIVE DENGAN SDK SIAP
    else {
      debugPrint("Membuka Gerbang Pembayaran Mobile SDK Flow.");
      _midtrans?.startPaymentUiFlow(token: snapToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menangkap data transaksi murni dari database Laravel yang dikirim via arguments
    final Map<String, dynamic> bookingData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String orderId = bookingData['order_id'] ?? 'SG-${DateTime.now().millisecondsSinceEpoch}';
    String status = bookingData['status'] ?? 'pending';
    String? snapToken = bookingData['snap_token']; 

    // Mengatasi TypeError String/Double ke Int
    int totalPrice = 0;
    if (bookingData['total_price'] != null) {
      var priceRaw = bookingData['total_price'];
      if (priceRaw is num) {
        totalPrice = priceRaw.toInt();
      } else {
        totalPrice = double.tryParse(priceRaw.toString())?.toInt() ?? 0;
      }
    }

    // 🛠️ VALIDASI AKTIVASI TOMBOL: Tombol menyala jika token dari backend sukses dibuat,
    // baik di environment Web ataupun Mobile.
    bool isButtonEnabled = snapToken != null && snapToken.isNotEmpty && (kIsWeb || _isMidtransReady);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text("Instruksi Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Info Total Pembayaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Total Pembayaran",
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp ${totalPrice.toString()}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Order ID: $orderId",
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Text(
              "Metode Pembayaran (Midtrans)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2F4B7C)),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankRow("Sistem Pembayaran:", "Online Gateway", isDark),
                  _buildBankRow("Status Booking:", status.toUpperCase(), isDark, isStatus: true),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Tombol Utama untuk Membuka Gerbang Pembayaran Midtrans
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Colors.green[700] : Colors.grey[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isButtonEnabled ? () => _mulaiPembayaran(snapToken) : null,
                child: isButtonEnabled
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            kIsWeb ? "Bayar Sekarang (Snap Web)" : "Bayar Sekarang (Snap)", 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ],
                      )
                    : const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Keterangan Tambahan
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pembayaran diverifikasi secara otomatis oleh sistem. Klik tombol di atas untuk memilih metode pembayaran Alfamart/Indomaret/E-Wallet/Virtual Account.",
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.amber[200] : Colors.amber[900], height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Cadangan: Langsung Cek Riwayat
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? const Color(0xFF3A5A98) : const Color(0xFF2F4B7C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/history');
                },
                child: Text("Lihat Riwayat Pemesanan",
                    style: TextStyle(color: isDark ? const Color(0xFF6A93D4) : const Color(0xFF2F4B7C), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankRow(String label, String value, bool isDark, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isStatus
                  ? Colors.orange
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}