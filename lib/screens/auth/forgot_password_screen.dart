import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController emailController =
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
        child: Padding(
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
                  Icons.lock_reset,
                  size: 70,
                  color: Color(0xFF00E5A8),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Lupa Kata Sandi",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  "Masukkan email yang terdaftar untuk mengatur ulang kata sandi",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 50),

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

                decoration:
                    InputDecoration(
                  hintText:
                      "example@gmail.com",

                  hintStyle:
                      const TextStyle(
                    color: Colors.grey,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFF1A2332,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),

                  prefixIcon:
                      const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
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
                    "Kirim Tautan Reset",

                    style: TextStyle(
                      color: Colors.black,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}