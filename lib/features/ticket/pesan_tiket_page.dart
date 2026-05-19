import 'package:flutter/material.dart';
import 'pencarian_basecamp_page.dart';

class PesanTiketPage extends StatelessWidget {
  const PesanTiketPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk list gunung, nanti bisa kamu hubungkan ke API /api/gunung
    final List<Map<String, dynamic>> daftarGunung = [
      {
        "nama": "Gunung Prau",
        "image": "assets/images/gunung_prau.jpg", // Sesuaikan asset lokalmu
        "weekday": "Rp 25.000",
        "weekend": "Rp 30.000",
      },
      {
        "nama": "Gunung Ciremai",
        "image": "assets/images/puncak_ciremai.jpg",
        "weekday": "Rp 50.000",
        "weekend": "Rp 62.500",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4B7C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pesan Tiket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Filter Provinsi
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: "Semua Provinsi",
                  items: <String>['Semua Provinsi', 'Jawa Barat', 'Jawa Tengah'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),

          // List Gunung
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: daftarGunung.length,
              itemBuilder: (context, index) {
                final gunung = daftarGunung[index];
                return GestureDetector(
                  onTap: () {
                    // Berpindah ke halaman Pencarian Basecamp dengan membawa data gunung
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PencarianBasecampPage(gunung: gunung),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Gunung
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.asset(
                            gunung['image'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        // Detail Tarif
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gunung['nama'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F4B7C),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Tarif Weekday", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(gunung['weekday'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Tarif Weekend", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(gunung['weekend'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}