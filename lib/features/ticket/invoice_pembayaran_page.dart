// lib/features/ticket/invoice_pembayaran_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class InvoicePembayaranPage extends StatefulWidget {
  const InvoicePembayaranPage({super.key});

  @override
  State<InvoicePembayaranPage> createState() => _InvoicePembayaranPageState();
}

class _InvoicePembayaranPageState extends State<InvoicePembayaranPage> {
  Future<void> _mulaiPembayaran(String? snapToken) async {
    if (snapToken == null || snapToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Token pembayaran tidak ditemukan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri url = Uri.parse(
      "https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken",
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membuka halaman pembayaran: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, dynamic> bookingData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    String orderId =
        bookingData['order_id'] ??
        'SG-${DateTime.now().millisecondsSinceEpoch}';

    String status = bookingData['status'] ?? 'pending';

    String? snapToken = bookingData['snap_token'];

    int totalPrice = 0;

    if (bookingData['total_price'] != null) {
      var priceRaw = bookingData['total_price'];

      if (priceRaw is num) {
        totalPrice = priceRaw.toInt();
      } else {
        totalPrice = double.tryParse(priceRaw.toString())?.toInt() ?? 0;
      }
    }

    bool isButtonEnabled = snapToken != null && snapToken.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Instruksi Pembayaran",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Total Pembayaran",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rp $totalPrice",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF6A93D4)
                          : const Color(0xFF2F4B7C),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Order ID: $orderId",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Metode Pembayaran (Midtrans)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2F4B7C),
              ),
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
                  _buildBankRow(
                    "Status Booking:",
                    status.toUpperCase(),
                    isDark,
                    isStatus: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? Colors.green[700]
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isButtonEnabled
                    ? () => _mulaiPembayaran(snapToken)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      kIsWeb ? "Bayar Sekarang (Snap Web)" : "Bayar Sekarang",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                      "Setelah pembayaran berhasil dilakukan, booking akan tetap berstatus PENDING sampai diverifikasi oleh admin basecamp.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.amber[200] : Colors.amber[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF3A5A98)
                        : const Color(0xFF2F4B7C),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main-history',
                    (route) => false,
                  );
                },
                child: Text(
                  "Lihat Riwayat Pemesanan",
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF6A93D4)
                        : const Color(0xFF2F4B7C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankRow(
    String label,
    String value,
    bool isDark, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
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
