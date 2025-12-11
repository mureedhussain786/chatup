import 'dart:typed_data';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

// Conditional import: real dart:io on mobile, lightweight stub on web
import 'file_stub.dart'
if (dart.library.io) 'dart:io' as io;

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final List<Map<String, String>> members;
  final Uint8List? groupIcon;
  final String? description;

  const GroupChatScreen({
    super.key,
    required this.groupName,
    required this.members,
    this.groupIcon,
    this.description,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  bool _showEmojiPicker = false;
  bool _isTyping = false;
  Uint8List? _pickedImage;
  Uint8List? _pickedVideo;
  VideoPlayerController? _videoController;

  bool _isGroupBlocked = false;
  bool _isGroupMuted = false;

  @override
  void initState() {
    super.initState();
    _loadGroupSettings();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupSettings() async {
    setState(() {
      _isGroupBlocked = false;
      _isGroupMuted = false;
    });
  }

  void _toggleBlock() {
    setState(() => _isGroupBlocked = !_isGroupBlocked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isGroupBlocked
              ? '${widget.groupName} has been blocked'
              : '${widget.groupName} has been unblocked',
        ),
        backgroundColor: _isGroupBlocked ? Colors.red : Colors.green,
      ),
    );
  }

  void _toggleMute() {
    setState(() => _isGroupMuted = !_isGroupMuted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isGroupMuted
              ? '${widget.groupName} has been muted'
              : '${widget.groupName} has been unmuted',
        ),
        backgroundColor: _isGroupMuted ? Colors.orange : Colors.green,
      ),
    );
  }

  void _showMoreOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                _isGroupBlocked ? Icons.block : Icons.block_outlined,
                color: _isGroupBlocked ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
              ),
              title: Text(
                _isGroupBlocked ? 'Unblock Group' : 'Block Group',
                style: TextStyle(
                  color: _isGroupBlocked ? Colors.red : (isDarkMode ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _toggleBlock();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                _isGroupMuted ? Icons.volume_off : Icons.volume_up,
                color: _isGroupMuted ? Colors.orange : (isDarkMode ? Colors.white : Colors.black),
              ),
              title: Text(
                _isGroupMuted ? 'Unmute Group' : 'Mute Group',
                style: TextStyle(
                  color: _isGroupMuted ? Colors.orange : (isDarkMode ? Colors.white : Colors.black),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _toggleMute();
                Navigator.pop(context);
              },
            ),
            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.info_outline, color: isDarkMode ? Colors.white : Colors.black),
              title: Text('Group Info',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
              onTap: () {
                Navigator.pop(context);
                _showGroupInfo();
              },
            ),
            ListTile(
              leading: Icon(Icons.people_outline, color: isDarkMode ? Colors.white : Colors.black),
              title: Text('View Members',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
              onTap: () {
                Navigator.pop(context);
                _showGroupMembers();
              },
            ),
            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Exit Group',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _exitGroup();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupInfo() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '${widget.groupName} Info',
          style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Name: ${widget.groupName}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${widget.description ?? "No description"}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Members: ${widget.members.length}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_isGroupBlocked ? "Blocked" : "Active"}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifications: ${_isGroupMuted ? "Muted" : "Enabled"}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: TextStyle(color: AppTheme.getActionButtonColor())),
          ),
        ],
      ),
    );
  }

  void _showGroupMembers() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          '${widget.groupName} Members',
          style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              final member = widget.members[index];
              final avatarUrl = member["avatarUrl"];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Icon(Icons.person, color: isDarkMode ? Colors.white70 : Colors.black54)
                      : null,
                ),
                title: Text(
                  member["name"] ?? 'Unknown',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: TextStyle(color: AppTheme.getActionButtonColor())),
          ),
        ],
      ),
    );
  }

  void _exitGroup() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Exit Group',
            style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : Colors.black)),
        content: Text(
          'Are you sure you want to exit ${widget.groupName}?',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', 
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You have exited ${widget.groupName}'),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[600],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty && _pickedImage == null && _pickedVideo == null) return;

    setState(() {
      _messages.add({
        'text': message,
        'image': _pickedImage,
        'video': _pickedVideo,
        'isSelf': true,
      });
      _messageController.clear();
      _pickedImage = null;
      _pickedVideo = null;
      _isTyping = false;
    });
  }

  Future<void> _pickMedia({required bool isImage}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.video,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isImage) {
          _pickedImage = result.files.single.bytes!;
        } else {
          _pickedVideo = result.files.single.bytes!;

          if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                  Text('Video preview not supported on web yet')),
            );
            _pickedVideo = null;
          } else {
            final path = result.files.single.path;
            if (path != null) {
              _videoController = VideoPlayerController.file(
                (io.File(path)) as dynamic,
              )
                ..initialize().then((_) {
                  if (!mounted) return;
                  setState(() {});
                  _videoController?.play();
                });
            }
          }
        }
      });
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Align(
      alignment:
      message['isSelf'] ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: message['isSelf']
              ? AppTheme.getSentMessageColor(isDarkMode)
              : AppTheme.getReceivedMessageColor(isDarkMode),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message['text'] != null &&
                message['text'].toString().isNotEmpty)
              Text(
                message['text'],
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getMessageTextColor(isDarkMode, message['isSelf']),
                ),
              ),
            if (message['image'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(message['image'], width: 200),
                ),
              ),
            if (message['video'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: (_videoController != null &&
                    _videoController!.value.isInitialized)
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
                    : Text(
                        "Loading video...",
                        style: TextStyle(
                          color: AppTheme.getMessageTextColor(isDarkMode, message['isSelf']),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          if (_pickedImage != null)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_pickedImage!, width: 150),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          if (_pickedVideo != null &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.emoji_emotions_outlined,
                    color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () =>
                    setState(() => _showEmojiPicker = !_showEmojiPicker),
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () => _pickMedia(isImage: true),
              ),
              IconButton(
                icon: Icon(Icons.videocam, color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () => _pickMedia(isImage: false),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onChanged: (val) =>
                      setState(() => _isTyping = val.isNotEmpty),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isTyping ? Icons.send : Icons.mic,
                  color: AppTheme.getActionButtonColor(),
                ),
                onPressed: _isTyping ? _sendMessage : () {},
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showEmojiPicker
                ? Container(
              key: const ValueKey("emoji"),
              height: 250,
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              child: emoji.EmojiPicker(
                onEmojiSelected: (category, emojiObj) {
                  _messageController.text += emojiObj.emoji;
                  setState(() => _isTyping = true);
                },
              ),
            )
                : const SizedBox.shrink(key: ValueKey("empty")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            if (widget.groupIcon != null)
              CircleAvatar(
                radius: 18,
                backgroundImage: MemoryImage(widget.groupIcon!),
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                child: Icon(Icons.group,
                    size: 20, color: isDarkMode ? Colors.white70 : Colors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.groupName,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      if (_isGroupBlocked)
                        _statusBadge('BLOCKED', Colors.red),
                      if (_isGroupMuted)
                        _statusBadge('MUTED', Colors.orange),
                    ],
                  ),
                  Text(
                    widget.description ?? '${widget.members.length} members',
                    style: TextStyle(
                        fontSize: 12, 
                        color: isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: _showMoreOptions,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageItem(_messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding:
      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
