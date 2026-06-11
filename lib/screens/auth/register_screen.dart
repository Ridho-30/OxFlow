import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              const Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Color(0xFF00E5A8),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Daftar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Nama Lengkap",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: nameController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: _inputDecoration(
                  "Masukkan nama lengkap",
                  Icons.person_outline,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Email",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: emailController,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: _inputDecoration(
                  "example@gmail.com",
                  Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Kata Sandi",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: true,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: _inputDecoration(
                  "••••••••",
                  Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Konfirmasi Kata Sandi",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    confirmPasswordController,
                obscureText: true,

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: _inputDecoration(
                  "••••••••",
                  Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () {},

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF00E5A8,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),

                  child: const Text(
                    "Daftar",

                    style: TextStyle(
                      color: Colors.black,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Sudah memiliki akun? Masuk",

                    style: TextStyle(
                      color:
                          Color(0xFF00E5A8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Colors.grey,
      ),

      filled: true,

      fillColor: const Color(
        0xFF1A2332,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),

      prefixIcon: Icon(
        icon,
        color: Colors.grey,
      ),
    );
  }
}