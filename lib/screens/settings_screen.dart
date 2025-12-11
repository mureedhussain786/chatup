import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_edit_screen.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

// Import placeholder setting pages
import 'settings_pages.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Initial profile data
  String name = "John Albert";
  String about = "Hey there! I am using ChatUp.";
  String phone = "+92 300 1234567";
  String link = "www.chatup.com/john";
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : const AssetImage("assets/images/profile.png")
              as ImageProvider,
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(about, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileEditScreen(
                    name: name,
                    about: about,
                    phone: phone,
                    link: link,
                    profileImage: profileImage,
                  ),
                ),
              );

              if (updatedProfile != null) {
                setState(() {
                  name = updatedProfile["name"] ?? name;
                  about = updatedProfile["about"] ?? about;
                  phone = updatedProfile["phone"] ?? phone;
                  link = updatedProfile["link"] ?? link;
                  if (updatedProfile["image"] != null) {
                    profileImage = updatedProfile["image"];
                  }
                });
              }
            },
          ),
          const Divider(),

          // Theme Toggle
          ListTile(
            leading: Icon(Icons.palette, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Theme", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text(isDarkMode ? "Dark Mode" : "Light Mode", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeThumbColor: AppTheme.primaryGreen,
              activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
            ),
          ),
          const Divider(),

          // Settings Options (Clickable)
          ListTile(
            leading: Icon(Icons.vpn_key, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Account", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Privacy, security, change number", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.lock, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Privacy", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Manage your privacy settings", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.chat, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Chats", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Theme, wallpapers, chat history", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatSettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Notifications", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Message, group & call tones", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.storage, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Storage and data", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Network usage, auto-download", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageSettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Help", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            subtitle: Text("Help center, contact us, privacy policy", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSettingsScreen())),
          ),
          ListTile(
            leading: Icon(Icons.people, color: isDarkMode ? Colors.white : Colors.black),
            title: Text("Invite a friend", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteFriendScreen())),
          ),
        ],
      ),
    );
  }
}
