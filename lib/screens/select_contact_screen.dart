import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_detail_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/user_model.dart';
import '../theme.dart';

class SelectContactScreen extends StatefulWidget {
  const SelectContactScreen({super.key});

  @override
  State<SelectContactScreen> createState() => _SelectContactScreenState();
}

class _SelectContactScreenState extends State<SelectContactScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        title: Text(
          "Select Contact",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search contacts...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Create Group option
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.group, color: Colors.white),
            ),
            title: Text(
              "Create Group",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              // );
            },
          ),

          const SizedBox(height: 8),

          // Contacts list from Firestore
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: chatProvider.getUsersStream(authProvider.user?.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No contacts found",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  );
                }

                final users = snapshot.data!;
                final filteredUsers = users.where((user) {
                  final query = _searchQuery.toLowerCase();
                  return user.name.toLowerCase().contains(query) ||
                      user.phone.contains(query);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      "No contacts found for '$_searchQuery'",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profileImageUrl.isNotEmpty
                            ? user.profileImageUrl
                            : 'https://placehold.co/100x100/6200ea/white?text=${user.name[0]}'),
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        user.phone,
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                      ),
                      onTap: () {
                        // === YAHAN PAR AHEM TABDEELI KI GAYI HAI ===
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              contact: user, // Pura UserModel object pass karein
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
