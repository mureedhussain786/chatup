import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Dummy call data
    final List<Map<String, dynamic>> callHistory = [
      {
        'name': 'Fatima',
        'type': 'voice',
        'missed': true,
        'time': 'Today, 10:45 AM',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg'
      },
      {
        'name': 'Hassan',
        'type': 'video',
        'missed': false,
        'time': 'Yesterday, 6:20 PM',
        'avatar': 'https://randomuser.me/api/portraits/men/32.jpg'
      },
      {
        'name': 'Ayesha',
        'type': 'voice',
        'missed': false,
        'time': 'Monday, 8:15 PM',
        'avatar': 'https://randomuser.me/api/portraits/women/65.jpg'
      },
      {
        'name': 'Ali',
        'type': 'video',
        'missed': true,
        'time': 'Sunday, 2:10 PM',
        'avatar': 'https://randomuser.me/api/portraits/men/15.jpg'
      },
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Calls",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          final isVoice = call['type'] == 'voice';
          final isMissed = call['missed'] as bool;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(call['avatar']),
            ),
            title: Text(
              call['name'],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isMissed ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            subtitle: Text(
              isMissed
                  ? "Missed ${isVoice ? 'voice' : 'video'} call"
                  : "You ${isVoice ? 'called' : 'video called'}",
              style: TextStyle(
                color: isMissed ? Colors.red : (isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  isVoice ? Icons.call : Icons.videocam,
                  color: AppTheme.primaryGreen,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  call['time'],
                  style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white70 : Colors.grey),
                ),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call details for ${call['name']}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Start a new call feature coming soon!"),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
        tooltip: "Start a call",
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}
