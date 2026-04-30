import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController nama = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F4B7C),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF2F4B7C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logosummitgo.png',
                height: 80,
              )
            ),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Nama", style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nama,
                      decoration: inputStyle("Masukkan Nama"),
                    ),

                    SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Email", style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: email,
                      decoration: inputStyle("Masukkan Email"),
                    ),

                    SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password", style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: inputStyle("Masukkan Password"),
                    ),

                    SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Konfirmasi Password",
                          style: TextStyle(fontSize: 12)),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: inputStyle("Ulangi Password"),
                    ),

                    SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2F4B7C),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (password.text != confirmPassword.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Password tidak sama"),
                              ),
                            );
                            return;
                          }

                          print("Register berhasil (simulasi)");
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sudah punya akun? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}