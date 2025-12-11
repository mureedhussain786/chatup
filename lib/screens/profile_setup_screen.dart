import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../widgets/app_input.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? profileImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        
        if (user != null) {
          profileImageUrl = await StorageService.uploadProfilePicture(
            userId: user.uid,
            imageFile: image,
          );
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeSetup() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        
        if (user != null) {
          await authProvider.createUserProfile(
            name: nameController.text.trim(),
            phone: user.phoneNumber ?? '',
            profileImageUrl: profileImageUrl,
            status: statusController.text.trim().isEmpty 
                ? 'Hey there! I am using ChatUp'
                : statusController.text.trim(),
          );

          if (!mounted) return;
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error setting up profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Add your name and profile picture to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 1),

                // Profile Setup Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            border: Border.all(
                              color: Colors.green,
                              width: 3,
                            ),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green,
                                  ),
                                )
                              : profileImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        profileImageUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_add,
                                      size: 60,
                                      color: Colors.green,
                                    ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isLoading ? 'Uploading...' : 'Tap to add photo',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name Field
                      AppInput(
                        controller: nameController,
                        label: 'Your Name',
                        hint: 'Enter your full name',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status Field
                      AppInput(
                        controller: statusController,
                        label: 'Status (Optional)',
                        hint: 'Hey there! I am using ChatUp',
                        maxLines: 2,
                        prefixIcon: const Icon(Icons.message),
                      ),

                      const SizedBox(height: 20),

                      // Complete Setup Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _completeSetup,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Complete Setup',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
