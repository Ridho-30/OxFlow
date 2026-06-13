import 'package:flutter/material.dart';

import '../navigation/main_navigation_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const Spacer(),

              const Center(
                child: Icon(
                  Icons.pie_chart,
                  size: 70,
                  color: Color(0xFF00E5A8),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "OxFlow",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 40),

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

                decoration: InputDecoration(
                  hintText: "example@gmail.com",

                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),

                  filled: true,

                  fillColor: const Color(0xFF1A2332),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
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

                decoration: InputDecoration(
                  hintText: "••••••••",

                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),

                  filled: true,

                  fillColor: const Color(0xFF1A2332),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),

                  suffixIcon: const Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ForgotPasswordScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    "Lupa Kata Sandi?",
                    style: TextStyle(
                      color: Color(0xFF00E5A8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainNavigationScreen(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF00E5A8),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    "Masuk",

                    style: TextStyle(
                      color: Colors.black,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Belum memiliki akun? ",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFF00E5A8),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}