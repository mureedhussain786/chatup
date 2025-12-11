import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../providers/theme_provider.dart';
import 'chat_detail_screen.dart';

class ChatProfileScreen extends StatefulWidget {
  // Ab hum poora UserModel object receive karenge
  final UserModel contact;

  const ChatProfileScreen({
    super.key,
    required this.contact,
  });

  @override
  State<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen> {
  late bool _isBlocked;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isBlocked = false; // Initial values
    _isMuted = false;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBlocked = prefs.getBool('${widget.contact.phone}_blocked') ?? false;
      _isMuted = prefs.getBool('${widget.contact.phone}_muted') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toggleBlock() {
    setState(() => _isBlocked = !_isBlocked);
    _savePreference('${widget.contact.phone}_blocked', _isBlocked);
    _showSnack(
      _isBlocked ? '${widget.contact.name} has been blocked' : '${widget.contact.name} has been unblocked',
      _isBlocked ? Colors.red : Colors.green,
    );
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _savePreference('${widget.contact.phone}_muted', _isMuted);
    _showSnack(
      _isMuted ? '${widget.contact.name} has been muted' : '${widget.contact.name} has been unmuted',
      _isMuted ? Colors.orange : Colors.green,
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Contact Info'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.contact.profileImageUrl.isNotEmpty
                        ? widget.contact.profileImageUrl
                        : 'https://placehold.co/100x100/6200ea/white?text=${widget.contact.name[0]}'),
                    radius: 55,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.contact.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.contact.phone,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.message, 'Message', () {
                        // === YAHAN PAR AHEM TABDEELI KI GAYI HAI ===
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              contact: widget.contact, // Pura UserModel object pass karein
                            ),
                          ),
                        );
                      }),
                      _buildActionButton(Icons.call, 'Call', () => _showSnack('Calling...', Colors.green)),
                      _buildActionButton(Icons.videocam, 'Video', () => _showSnack('Video calling...', Colors.green)),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contact Details and Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.contact.status.isNotEmpty)
                    _buildDetailTile(Icons.info_outline, 'Status', widget.contact.status),

                  const SizedBox(height: 20),

                  _buildActionTile(
                    _isBlocked ? Icons.block : Icons.block_outlined,
                    _isBlocked ? 'Unblock' : 'Block',
                  widget.contact.name,
                    _toggleBlock,
                    color: Colors.red,
                  ),
                  _buildActionTile(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    _isMuted ? 'Unmute' : 'Mute',
                    'Notifications',
                    _toggleMute,
                  ),
                  _buildActionTile(
                      Icons.report,
                      'Report',
                    widget.contact.name,
                          () => _showSnack('Contact reported', Colors.red),
                      color: Colors.red
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
