import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? webImageBytes;
  String? imagePath;

  final picker = ImagePicker();
  String name = "You";
  String phone = "+92 300 1234567";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();

    // Animation setup (for splash-like smooth entry)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final base64Image = prefs.getString('self_avatar_web');
      if (base64Image != null) {
        setState(() {
          webImageBytes = base64Decode(base64Image);
        });
      }
    } else {
      final path = prefs.getString('self_avatar');
      if (path != null) {
        setState(() {
          imagePath = path;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        final base64Image = base64Encode(bytes);
        await prefs.setString('self_avatar_web', base64Image);
        setState(() {
          webImageBytes = bytes;
        });
      } else {
        await prefs.setString('self_avatar', picked.path);
        setState(() {
          imagePath = picked.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;

    if (kIsWeb && webImageBytes != null) {
      avatar = MemoryImage(webImageBytes!);
    } else if (!kIsWeb && imagePath != null) {
      avatar = FileImage(File(imagePath!));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF075E54), Color(0xFF25D366)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Profile Picture with animation effect
                GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      Hero(
                        tag: "profilePic",
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: avatar,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          child: avatar == null
                              ? const Icon(Icons.person,
                              size: 70, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to change",
                        style:
                        TextStyle(fontSize: 12, color: Colors.grey[200]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // User Info
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),

                const SizedBox(height: 40),

                // Change Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF075E54),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Change Profile Picture",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
