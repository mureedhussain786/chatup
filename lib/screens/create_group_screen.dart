import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'group_chat_screen.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../widgets/app_input.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> dummyContacts = List.generate(
    50,
        (index) => {
      "id": "${index + 1}",
      "name": "Contact ${index + 1}",
      "avatarUrl": "https://i.pravatar.cc/150?img=${index + 1}",
    },
  );

  final Set<String> selectedContactIds = {};
  final TextEditingController _groupNameController = TextEditingController();

  Uint8List? _groupIcon;
  bool _isLoadingIcon = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleSelection(String contactId) {
    setState(() {
      if (selectedContactIds.contains(contactId)) {
        selectedContactIds.remove(contactId);
      } else {
        selectedContactIds.add(contactId);
      }
    });
  }

  Future<void> _pickGroupIcon() async {
    if (!mounted) return;
    setState(() => _isLoadingIcon = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _groupIcon = result.files.single.bytes!;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingIcon = false);
      }
    }
  }

  void _createGroup() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (selectedContactIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    final members = dummyContacts
        .where((c) => selectedContactIds.contains(c["id"]))
        .toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(
          groupName: groupName,
          members: members,
          groupIcon: _groupIcon,
        ),
      ),
    );
  }

  Widget _buildGroupInfoSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickGroupIcon,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    backgroundImage:
                    _groupIcon != null ? MemoryImage(_groupIcon!) : null,
                    child: _groupIcon == null
                        ? Icon(Icons.group,
                        size: 50, color: isDarkMode ? Colors.white : Colors.grey)
                        : null,
                  ),
                  if (_isLoadingIcon)
                    const Positioned.fill(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppInput(
              controller: _groupNameController,
              label: 'Group Name',
              hint: 'Enter group name',
              prefixIcon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
              keyboardType: TextInputType.text,
              maxLength: 25,
            ),
            const SizedBox(height: 8),
            Text(
              '${selectedContactIds.length} participants selected',
              style: TextStyle(color: AppTheme.primaryGreen, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSelected = selectedContactIds.contains(contact["id"]);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(contact["avatarUrl"]!),
      ),
      title: Text(
        contact["name"]!,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? AppTheme.primaryGreen : (isDarkMode ? Colors.white54 : Colors.grey),
      ),
      onTap: () => _toggleSelection(contact["id"]!),
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
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        title: Text(
          "Create Group",
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: AppTheme.primaryGreen),
            onPressed: _createGroup,
          )
        ],
      ),
      body: Column(
        children: [
          _buildGroupInfoSection(),
          Expanded(
            child: ListView.builder(
              itemCount: dummyContacts.length,
              itemBuilder: (context, index) {
                return _buildContactTile(dummyContacts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
