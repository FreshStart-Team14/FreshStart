import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Freshagram extends StatefulWidget {
  @override
  _FreshagramState createState() => _FreshagramState();
}

class _FreshagramState extends State<Freshagram> {
  final TextEditingController _messageController = TextEditingController();
  late final User _currentUser;
  String? _username;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _loadUsername();
  }

  Future<void> _loadUsername() async{
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
    if (message.isEmpty || _username == null) return;

    final senderName = _currentUser.displayName ?? _currentUser.email ?? 'Unknown';
    try{
    await FirebaseFirestore.instance.collection('group_messages').add({
      'sender': _username!,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
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
      appBar: AppBar(
        title: Text('Freshagram Group'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
        return const Center(child: Text('No messages yet. Say hello!'));
      }

      final messages = snapshot.data!.docs;

      return ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isCurrentUser = msg['sender'] == _username;

          return Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Colors.green.shade200
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg['sender']!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.green.shade900)),
                  const SizedBox(height: 4),
                  Text(msg['sender']!, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green.shade700),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
