// --- Imports ---
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udp/udp.dart';
import 'user_session.dart';

// --- Configuration ---
const String NODE_A_IP = "192.168.4.1"; // Center Node (Access Point)
const int UDP_PORT = 4210;

// Data model for a chat message
class Message {
  final String text;
  final String sender;
  final bool isMe;

  Message({required this.text, required this.sender, required this.isMe});
}

// --- ChatProvider Class ---
class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  String _status = "Connect to 'ESP32_Mesh_AP' to begin.";
  String _userName = UserSession.name ?? UserSession.email ?? "User-${DateTime.now().second}";
  UDP? _udpSocket;
  StreamSubscription<Datagram?>? _udpListener;

  List<Message> get messages => _messages;
  String get status => _status;
  String get userName => _userName;

  ChatProvider() {
    startUdpListener(); // Start listening immediately
  }

  void setUserName(String name) {
    if (name.isNotEmpty) {
      _userName = name;
      _updateStatus("Name set to '$name'. Listening for messages.");
      notifyListeners();
    }
  }

  void _updateStatus(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  // --- Start UDP Listener for broadcasts from Node A ---
  Future<void> startUdpListener() async {
    _updateStatus("Starting UDP listener...");
    try {
      _udpSocket = await UDP.bind(Endpoint.any(port: Port(UDP_PORT)));
      _updateStatus("Listening on UDP $UDP_PORT...");

      _udpListener = _udpSocket?.asStream().listen(
        (Datagram? datagram) {
          if (datagram != null) {
            try {
              final jsonString = utf8.decode(datagram.data);
              final Map<String, dynamic> data = jsonDecode(jsonString);
              final sender = data['sender'] ?? 'Unknown';
              final message = data['message'] ?? '';

              // Filter out messages from the current user to avoid duplicates
              if (sender != _userName) {
                _messages.add(
                  Message(
                    text: message,
                    sender: sender,
                    isMe:
                        false, // Messages from others are not from the current user
                  ),
                );
                notifyListeners();
              }
            } catch (e) {
              print("Error parsing UDP message: $e");
            }
          }
        },
        onError: (e) {
          _updateStatus("UDP Listener error.");
        },
      );
    } catch (e) {
      _updateStatus("Failed to bind UDP: $e");
    }
  }

  // --- Send message to Node A ---
  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    // Add the message locally first to avoid duplicates
    final localMessage = Message(
      text: messageText.trim(),
      sender: _userName,
      isMe: true,
    );
    _messages.add(localMessage);
    notifyListeners();

    final payload = {"sender": _userName, "message": messageText.trim()};
    final jsonData = utf8.encode(jsonEncode(payload));

    try {
      await _udpSocket?.send(
        jsonData,
        Endpoint.broadcast(port: Port(UDP_PORT)),
      );
      _updateStatus("Message sent to all users (broadcast)");
    } catch (e) {
      _updateStatus("Send failed. Check Wi-Fi.");
      print("UDP Send Error: $e");
    }
  }

  @override
  void dispose() {
    _udpListener?.cancel();
    _udpSocket?.close();
    super.dispose();
  }
}

// --- Main App ---
class MM32ChatPage extends StatelessWidget {
  const MM32ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const ChatScreen(),
    );
  }
}

// --- Chat Screen UI ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<ChatProvider>().userName;
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(_textController.text);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Your Name"),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().setUserName(_nameController.text);
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ESP32 Mesh Chat'),
            Text(
              chatProvider.status,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Change Name',
            onPressed: _showNameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: provider.messages.length,
                itemBuilder: (context, index) =>
                    MessageBubble(message: provider.messages[index]),
              ),
            ),
          ),
          MessageComposer(controller: _textController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

// --- Message Bubble Widget ---
class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Message Composer Widget ---
class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(context).primaryColor,
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
