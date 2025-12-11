import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedContactsScreen extends StatefulWidget {
  const BlockedContactsScreen({super.key});

  @override
  State<BlockedContactsScreen> createState() => _BlockedContactsScreenState();
}

class _BlockedContactsScreenState extends State<BlockedContactsScreen> {
  List<Map<String, String>> blockedContacts = [];
  late List<Map<String, String>> allContacts;
  late List<Map<String, String>> recentChats;

  @override
  void initState() {
    super.initState();
    _loadContactsAndChats();
    _loadBlocked();
  }

  Future<void> _loadBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList('blocked_contacts') ?? [];
    setState(() {
      blockedContacts =
          allContacts.where((c) => savedNames.contains(c['name'])).toList();
    });
  }

  Future<void> _saveBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'blocked_contacts',
      blockedContacts.map((c) => c['name']!).toList(),
    );
  }

  void _loadContactsAndChats() {
    allContacts = List.generate(
      50,
          (index) => {
        "name": "Contact ${index + 1}",
        "avatarUrl":
        "https://randomuser.me/api/portraits/men/${index % 50}.jpg",
      },
    );

    recentChats = List.generate(50, (index) {
      return {
        'name': 'Contact ${index + 1}',
        'message': 'Hello from Contact ${index + 1}',
        'phone': '03001234${(100 + index)}',
        'time': '${10 + index % 12}:${index % 60} AM',
        'avatar': 'https://randomuser.me/api/portraits/women/${index % 50}.jpg',
      };
    }).sublist(6, 13);
  }

  void _blockContact(Map<String, String> contact) {
    if (!blockedContacts.any((c) => c['name'] == contact['name'])) {
      setState(() => blockedContacts.add(contact));
      _saveBlocked();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${contact['name']} has been blocked'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _unblockContact(Map<String, String> contact) {
    setState(() =>
        blockedContacts.removeWhere((c) => c['name'] == contact['name']));
    _saveBlocked();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact['name']} has been unblocked'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showBlockContactDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Block Contact",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: const Text(
          "Choose how you want to block a contact:",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactSelectionDialog();
            },
            child: const Text(
              "From Contacts",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRecentChatsDialog();
            },
            child: const Text(
              "From Recent Chats",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSelectionDialog() {
    final availableContacts = allContacts
        .where((contact) =>
    !blockedContacts.any((c) => c['name'] == contact["name"]))
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Select Contact to Block",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableContacts.length,
            itemBuilder: (context, index) {
              final contact = availableContacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(contact["avatarUrl"]!),
                ),
                title: Text(
                  contact["name"]!,
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  _blockContact(contact);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecentChatsDialog() {
    final availableChats = recentChats
        .where((chat) =>
    !blockedContacts.any((c) => c['name'] == chat['name']))
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Select from Recent Chats",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableChats.length,
            itemBuilder: (context, index) {
              final chat = availableChats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(chat['avatar']!),
                ),
                title: Text(
                  chat['name']!,
                  style: const TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  chat['message']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  chat['time']!,
                  style: const TextStyle(color: Colors.green),
                ),
                onTap: () {
                  _blockContact({
                    "name": chat['name']!,
                    "avatarUrl": chat['avatar']!,
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // match splash background
      appBar: AppBar(
        title: const Text(
          "Blocked Contacts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white70,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: blockedContacts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No blocked contacts",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              "Tap the + button to block a contact",
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: blockedContacts.length,
        itemBuilder: (_, index) {
          final contact = blockedContacts[index];
          return Card(
            color: Colors.white,
            margin:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(contact["avatarUrl"]!),
              ),
              title: Text(
                contact["name"]!,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black),
              ),
              subtitle: const Text(
                "Blocked",
                style: TextStyle(color: Colors.red),
              ),
              trailing: IconButton(
                icon:
                const Icon(Icons.remove_circle, color: Colors.green),
                onPressed: () => _unblockContact(contact),
                tooltip: "Unblock contact",
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBlockContactDialog,
        backgroundColor: Colors.green,
        tooltip: "Block a contact",
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
