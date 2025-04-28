import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intrencity/models/chat_message_model.dart';
import 'package:intrencity/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:intrencity/widgets/custom_text_form_field.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  final String receiverId;
  final String receiverName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      senderId: currentUserId!,
      receiverId: widget.receiverId,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    // Get conversation ID (sorted user IDs concatenated)
    final users = [currentUserId!, widget.receiverId]..sort();
    final conversationId = users.join('_');

    // Add message to messages subcollection
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toJson());

    // Update or create conversation document
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .set({
      'participants': users,
      'lastMessage': message.message,
      'lastMessageTime': message.timestamp,
    });

    _messageController.clear();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // If message is from today, show only time
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // If message is from yesterday
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      // For older messages, show date and time
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = [currentUserId!, widget.receiverId]..sort();
    final conversationId = users.join('_');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final message = ChatMessage.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>,
                      );
                      final isMe = message.senderId == currentUserId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? primaryBlue : Colors.yellow,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _messageController,
                      hintText: 'Type a message...',
                      maxLines: 1,
                      prefixIcon: Icons.message,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
