import 'dart:convert';
import 'package:epams/DataCell/DataCellDashboard.dart';
import 'package:epams/Director/DirectorDashboard.dart';
import 'package:epams/HOD/HODDashboard.dart';
import 'package:epams/Student/StudentDashboard.dart';
import 'package:epams/Teacher/TeacherDashboard.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscurePassword = true;


  Future<void> login() async {
    final url = Uri.parse(
      '$Url/Users/Login?id=${username.text.trim()}&password=${password.text.trim()}',
    );

    final response = await http.post(url);
      
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String role = data['role'];
      final String userid=data['userId'];

      Widget nextScreen;

      switch (role) {
        case 'HOD':
          nextScreen = const HodDashboard();
          break;
        case 'Teacher':
          nextScreen = Teacherdashboard(teacherID: userid);
          break;
        case 'Student':
          nextScreen =  Studentdashboard(studentId: userid);
          break;
        case 'Director':
          nextScreen = const Directordashboard();
          break;
        case 'DataCell':
          nextScreen = const DataCellDashboard();
          break;
        default:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Unknown user role')));
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/logo.jpeg'),
                ),

                const SizedBox(height: 20),

                Text(
                  'Employee Performance Appraisal \n System',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),

                Text(
                  'Welcome back! Please login to continue',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text('Username', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: username,
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          filled: true,
                          fillColor: const Color(0xFFF3F8F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Text('Password', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      TextField(
                        obscureText: _obscurePassword,
                        controller: password,

                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          fillColor: const Color(0xFFF3F8F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A8F3C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: login,

                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  '© Barani Institute of Information Technology\nAll rights reserved',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
