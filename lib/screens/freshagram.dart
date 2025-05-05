import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class Freshagram extends StatefulWidget {
  @override
  _FreshagramState createState() => _FreshagramState();
}

class _FreshagramState extends State<Freshagram> {
  final TextEditingController _messageController = TextEditingController();
  late final User _currentUser;
  String? _username;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _loadUsername();
  }
  Future<void> _sendImage() async {
  if (!await _requestImagePermissions()) return;

  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image == null) return;

  try {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('group_images/$fileName.jpg');

    final file = File(image.path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

    final imageUrl = await ref.getDownloadURL();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).get();
    final avatar = userDoc.data()?['selectedAvatar'];

    await FirebaseFirestore.instance.collection('group_messages').add({
      'sender': _username!,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'avatar': avatar,
    });
  } catch (e) {
    print('Error sending image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send image. Please try again')),
    );
  }
}
String formatChatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(date.year, date.month, date.day);

  final difference = today.difference(messageDate).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  } else if (difference < 7) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  } else if (now.year == date.year) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  } else {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

Future<bool> _requestImagePermissions() async {
  final status = await Permission.photos.request();
  if (status.isGranted) {
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permission to access photos is required.')),
    );
    return false;
  }
}

  Future<void> _takePhoto() async {
  final cameraPermission = await Permission.camera.request();
  final storagePermission = await Permission.photos.request(); // READ_MEDIA_IMAGES for Android 13+

  if (!cameraPermission.isGranted || !storagePermission.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera and storage permissions are required.')),
    );
    return;
  }

  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  if (photo == null) return;

  try {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('group_images/$fileName.jpg');

    final file = File(photo.path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

    final imageUrl = await ref.getDownloadURL();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).get();
    final avatar = userDoc.data()?['selectedAvatar'];

    await FirebaseFirestore.instance.collection('group_messages').add({
      'sender': _username!,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'avatar': avatar,
    });
  } catch (e) {
    print('Error taking photo: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send photo. Please try again')),
    );
  }
}


  Future<void> _loadUsername() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .get();

    setState(() {
      _username = doc.data()?['username'] ?? 'Unknown';
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).get();
    final avatar = userDoc.data()?['selectedAvatar'];
    if (message.isEmpty || _username == null) return;

    try {
      await FirebaseFirestore.instance.collection('group_messages').add({
        'sender': _username!,
        'message': message, 
        'timestamp': FieldValue.serverTimestamp(),
        'avatar': avatar,
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message. Please try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Freshagram',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.blue),
            onPressed: () {
              // Add group settings or options here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Watermark background
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[100]!,
                          Colors.grey[100]!.withOpacity(0.8),
                          Colors.grey[100]!.withOpacity(0.6),
                          Colors.grey[100]!.withOpacity(0.4),
                        ],
                        stops: const [0.0, 0.2, 0.4, 0.6],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.1,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              size: 120,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Freshagram',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Chat messages
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('group_messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No messages yet. Say hello!'));
                    }

                    final messages = snapshot.data!.docs;
DateTime? lastMessageDate;

return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: messages.length,
  itemBuilder: (context, index) {
    final msg = messages[index];
    final data = msg.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    final messageDate = timestamp?.toDate() ?? DateTime.now();
    final isCurrentUser = data['sender'] == _username;

    final bool showDateHeader = index == 0 ||
      formatChatDate(messageDate) != formatChatDate((messages[index - 1].data() as Map<String, dynamic>)['timestamp']?.toDate() ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showDateHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              formatChatDate(messageDate),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                backgroundImage: data['avatar'] != null
                    ? AssetImage(data['avatar']) as ImageProvider
                    : null,
                child: data['avatar'] == null
                    ? Text(
                        data['sender']![0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            const SizedBox(width: 8),
            Flexible(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.75,
      minWidth: 48,
    ),
    child: IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                data['sender']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blue[900],
                ),
              ),
            if (!isCurrentUser) const SizedBox(height: 4),
            if (data.containsKey('imageUrl') && data['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data['imageUrl'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (data['message'] != null &&
                data['message'].toString().isNotEmpty)
              Text(
                data['message']!,
                style: TextStyle(
                  fontSize: 16,
                  color: isCurrentUser ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                formatTime(messageDate),
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)


          ],
        ),
      ],
    );
  },
);

                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.image, color: Colors.blue),
                      onPressed: _sendImage,
                    ),
                  ),
                  Container(
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(20),
  ),
  child: IconButton(
    icon: const Icon(Icons.camera_alt, color: Colors.blue),
    onPressed: _takePhoto,
  ),
),
const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
