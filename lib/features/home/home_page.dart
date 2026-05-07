import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List> getGunung() async {
  final response = await http.get(
    Uri.parse("http://192.168.100.6:8000/api/gunungs"),
  );

  return jsonDecode(response.body);
}

class HomePage extends StatelessWidget {
  final List<String> gunung = [
    "Gunung Ciremai",
    "Gunung Rinjani",
    "Gunung Semeru",
    "Gunung Merbabu",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Color(0xFF2F4B7C),
        title: Row(
          children: [
            Image.asset('assets/images/logosummitgo.png', height: 30),
            SizedBox(width: 100),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari gunung yang ingin kamu daki...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: gunung.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return gunungCard(context, gunung[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget gunungCard(BuildContext context, String nama) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              color: Colors.grey,
            ),
            child: Center(child: Icon(Icons.image)),
          ),

          Padding(
            padding: EdgeInsets.all(8),
            child: Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("Jawa Barat", style: TextStyle(fontSize: 12)),
          ),

          Spacer(),

          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                bool isLogin = false;

                if (!isLogin) {
                  Navigator.pushNamed(context, '/login');
                } else {
                  Navigator.pushNamed(context, '/ticket');
                }
              },
              child: Text("Pesan"),
            ),
          ),
        ],
      ),
    );
  }
}
