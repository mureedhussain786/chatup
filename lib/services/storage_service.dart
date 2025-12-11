import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../firebase_options.dart';

/// Comprehensive Firebase Storage service for handling file uploads and downloads
class StorageService {
  // Use default instance first, fallback to explicit bucket if needed
  static FirebaseStorage get _storage {
    try {
      // Try default instance first (uses bucket from google-services.json)
      return FirebaseStorage.instance;
    } catch (e) {
      // Fallback to explicit bucket configuration
      if (kDebugMode) {
        print('[StorageService] Using explicit bucket configuration');
      }
      return FirebaseStorage.instanceFor(
        bucket: DefaultFirebaseOptions.currentPlatform.storageBucket,
      );
    }
  }

  static void _logDebug(String message) {
    if (kDebugMode) {
      print('[StorageService] $message');
    }
  }

  static void _logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[StorageService] ERROR: $message');
      if (error != null) print('[StorageService] Error details: $error');
      if (stackTrace != null) print('[StorageService] StackTrace: $stackTrace');
    }
  }

  // Storage references
  static Reference get _profileImages => _storage.ref().child('profile_images');
  static Reference get _chatImages => _storage.ref().child('chat_images');
  static Reference get _chatVideos => _storage.ref().child('chat_videos');
  static Reference get _chatDocuments => _storage.ref().child('chat_documents');
  static Reference get _chatAudio => _storage.ref().child('chat_audio');
  static Reference get _statusImages => _storage.ref().child('status_images');
  static Reference get _statusVideos => _storage.ref().child('status_videos');
  static Reference get _groupImages => _storage.ref().child('group_images');

  // ==================== PROFILE IMAGES ====================

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required String uid,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _profileImages.child(fileName);
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Profile image uploaded: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      rethrow;
    }
  }

  /// Upload profile image from XFile
  static Future<String> uploadProfileImageFromXFile({
    required String uid,
    required XFile imageFile,
  }) async {
    try {
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _profileImages.child(fileName);
      
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Profile image uploaded: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      rethrow;
    }
  }

  /// Upload profile picture (legacy method for compatibility)
  static Future<String> uploadProfilePicture({
    required String userId,
    required XFile imageFile,
  }) async {
    return uploadProfileImageFromXFile(uid: userId, imageFile: imageFile);
  }

  /// Delete profile image
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      
      if (kDebugMode) {
        print('Profile image deleted: $imageUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile image: $e');
      }
      rethrow;
    }
  }

  // ==================== CHAT MEDIA ====================

  /// Upload chat image
  static Future<String> uploadChatImage({
    required String chatId,
    required String messageId,
    required XFile imageFile,
  }) async {
    _logDebug('uploadChatImage called');
    _logDebug('chatId: $chatId, messageId: $messageId');
    _logDebug('Image file path: ${imageFile.path}');
    _logDebug('Image file name: ${imageFile.name}');
    
    return _uploadWithRetry(
      pathBuilder: () {
        // Match storage rules: /chat_images/{chatId}/{messageId}
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _chatImages.child(chatId).child(messageId).child(fileName);
        _logDebug('Built image reference: ${ref.fullPath}');
        return ref;
      },
      file: File(imageFile.path),
      metadata: SettableMetadata(contentType: 'image/jpeg'),
    );
  }

  /// Upload chat video
  static Future<String> uploadChatVideo({
    required String chatId,
    required String messageId,
    required XFile videoFile,
  }) async {
    _logDebug('uploadChatVideo called');
    _logDebug('chatId: $chatId, messageId: $messageId');
    _logDebug('Video file path: ${videoFile.path}');
    
    // Match storage rules: /chat_videos/{chatId}/{messageId}
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    return _uploadWithRetry(
      pathBuilder: () {
        final ref = _chatVideos.child(chatId).child(messageId).child(fileName);
        _logDebug('Built video reference: ${ref.fullPath}');
        return ref;
      },
      file: File(videoFile.path),
      metadata: SettableMetadata(contentType: 'video/mp4'),
    );
  }

  /// Upload chat document
  static Future<String> uploadChatDocument({
    required String chatId,
    required String messageId,
    required File documentFile,
    required String fileName,
  }) async {
    _logDebug('uploadChatDocument called');
    _logDebug('chatId: $chatId, messageId: $messageId');
    _logDebug('Document file path: ${documentFile.path}');
    _logDebug('Document file name: $fileName');
    
    final fileExtension = fileName.split('.').last;
    // Match storage rules: /chat_documents/{chatId}/{messageId}
    final docFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    return _uploadWithRetry(
      pathBuilder: () {
        final ref = _chatDocuments.child(chatId).child(messageId).child(docFileName);
        _logDebug('Built document reference: ${ref.fullPath}');
        return ref;
      },
      file: documentFile,
      metadata: SettableMetadata(contentType: 'application/octet-stream'),
    );
  }

  /// Upload audio message
  static Future<String> uploadAudioMessage({
    required String chatId,
    required String messageId,
    required File audioFile,
  }) async {
    _logDebug('uploadAudioMessage called');
    _logDebug('chatId: $chatId, messageId: $messageId');
    _logDebug('Audio file path: ${audioFile.path}');
    
    // Match storage rules: /chat_audio/{chatId}/{messageId}
    final audioFileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    return _uploadWithRetry(
      pathBuilder: () {
        final ref = _chatAudio.child(chatId).child(messageId).child(audioFileName);
        _logDebug('Built audio reference: ${ref.fullPath}');
        return ref;
      },
      file: audioFile,
      metadata: SettableMetadata(contentType: 'audio/mp4'),
    );
  }

  // ===== Common upload with one retry to handle stale resumable sessions =====
  static Future<String> _uploadWithRetry({
    required Reference Function() pathBuilder,
    required File file,
    required SettableMetadata metadata,
  }) async {
    // Get actual bucket from storage instance
    final bucket = _storage.app.options.storageBucket ?? DefaultFirebaseOptions.currentPlatform.storageBucket;
    _logDebug('=== Starting upload ===');
    _logDebug('Storage bucket: $bucket');
    _logDebug('Storage app name: ${_storage.app.name}');
    _logDebug('File path: ${file.path}');
    _logDebug('File exists: ${await file.exists()}');
    if (await file.exists()) {
      final fileSize = await file.length();
      _logDebug('File size: $fileSize bytes');
      if (fileSize == 0) {
        _logError('File is empty!');
        throw Exception('Cannot upload empty file');
      }
    } else {
      _logError('File does not exist at path: ${file.path}');
      throw Exception('File not found: ${file.path}');
    }
    _logDebug('Content type: ${metadata.contentType}');

    Future<String> _attempt(int attemptNumber) async {
      final ref = pathBuilder();
      final fullPath = ref.fullPath;
      _logDebug('Attempt $attemptNumber: Uploading to path: $fullPath');
      _logDebug('Full storage URL: gs://$bucket/$fullPath');
      
      try {
        // First try putFile (more efficient for large files)
        _logDebug('Attempt $attemptNumber: Trying putFile...');
        final uploadTask = ref.putFile(file, metadata);
        
        // Listen to upload progress
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          _logDebug('Upload progress: ${progress.toStringAsFixed(1)}%');
        });
        
        final snapshot = await uploadTask;
        _logDebug('Upload completed successfully');
        final downloadUrl = await snapshot.ref.getDownloadURL();
        _logDebug('Download URL: $downloadUrl');
        return downloadUrl;
      } on FirebaseException catch (e) {
        _logError('putFile failed on attempt $attemptNumber', e);
        _logDebug('Attempt $attemptNumber: Falling back to putData...');
        
        // Fallback: read bytes and upload with putData (helps when file paths are not directly readable)
        try {
          final bytes = await file.readAsBytes();
          _logDebug('Read ${bytes.length} bytes from file');
          final uploadTask = ref.putData(bytes, metadata);
          
          uploadTask.snapshotEvents.listen((snapshot) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
            _logDebug('Upload progress (putData): ${progress.toStringAsFixed(1)}%');
          });
          
          final snapshot = await uploadTask;
          _logDebug('putData upload completed successfully');
          final downloadUrl = await snapshot.ref.getDownloadURL();
          _logDebug('Download URL: $downloadUrl');
          return downloadUrl;
        } catch (e2) {
          _logError('putData also failed on attempt $attemptNumber', e2);
          rethrow;
        }
      } catch (e) {
        _logError('Unexpected error on attempt $attemptNumber', e);
        rethrow;
      }
    }

    try {
      return await _attempt(1);
    } on FirebaseException catch (e) {
      final code = e.code;
      final message = e.message ?? 'No message';
      _logError('Upload failed with code: $code', e);
      _logDebug('Error message: $message');
      
      // Retry once on object-not-found / canceled resumable session
      if (code == 'object-not-found' || code == 'canceled' || code == '-13010' || code == '-13040') {
        _logDebug('Retrying upload after error code: $code');
        await Future.delayed(const Duration(seconds: 1));
        return await _attempt(2);
      }
      rethrow;
    } catch (e, stackTrace) {
      _logError('Fatal upload error', e, stackTrace);
      rethrow;
    }
  }

  // ==================== STATUS MEDIA ====================

  /// Upload status image
  static Future<String> uploadStatusImage({
    required String userId,
    required String statusId,
    required XFile imageFile,
  }) async {
    try {
      final fileName = '${userId}_${statusId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _statusImages.child(fileName);
      
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Status image uploaded: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading status image: $e');
      }
      rethrow;
    }
  }

  /// Upload status video
  static Future<String> uploadStatusVideo({
    required String userId,
    required String statusId,
    required XFile videoFile,
  }) async {
    try {
      final fileName = '${userId}_${statusId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _statusVideos.child(fileName);
      
      final uploadTask = ref.putFile(File(videoFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Status video uploaded: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading status video: $e');
      }
      rethrow;
    }
  }

  // ==================== GROUP MEDIA ====================

  /// Upload group image
  static Future<String> uploadGroupImage({
    required String groupId,
    required XFile imageFile,
  }) async {
    try {
      final fileName = '${groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _groupImages.child(fileName);
      
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Group image uploaded: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading group image: $e');
      }
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file size: $e');
      }
      return 0;
    }
  }

  /// Check if file size is within limits
  static bool isFileSizeValid(int fileSizeBytes, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeBytes <= maxSizeBytes;
  }

  /// Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  /// Check if file type is supported for images
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file type is supported for videos
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(extension);
  }

  /// Check if file type is supported for documents
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['pdf', 'doc', 'docx', 'txt', 'rtf', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension);
  }

  /// Check if file type is supported for audio
  static bool isAudioFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'].contains(extension);
  }

  /// Delete file from storage
  static Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      
      if (kDebugMode) {
        print('File deleted: $downloadUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      rethrow;
    }
  }

  /// Get file metadata
  static Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file metadata: $e');
      }
      return null;
    }
  }

  /// Get download URL for a file
  static Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download URL: $e');
      }
      rethrow;
    }
  }

  /// Upload file with progress tracking
  static Future<String> uploadFileWithProgress({
    required Reference ref,
    required File file,
    required Function(double progress) onProgress,
  }) async {
    try {
      final uploadTask = ref.putFile(file);
      
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file with progress: $e');
      }
      rethrow;
    }
  }
}
