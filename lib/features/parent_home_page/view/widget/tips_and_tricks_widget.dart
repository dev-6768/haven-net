import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:haven_net/secret.dart';
import 'package:haven_net/utils/utilities.dart';
import 'package:http/http.dart' as http;

class TipsAndTricksWidget extends StatelessWidget {
  final String email;
  const TipsAndTricksWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChatScreen(userEmail: email);
  }
}

class ChatScreen extends StatefulWidget {
  final String userEmail;
  const ChatScreen({super.key, required this.userEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<List<Map<String, dynamic>>> _messages = ValueNotifier([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    var snapshot = await _firestore.collection('bot_messages').doc(widget.userEmail).get();
    if (snapshot.exists) {
      setState(() {
        _messages.value = List<Map<String, dynamic>>.from(snapshot.data()?['messages'] ?? []);
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;
    
    final newMessage = {'user': message, 'model': '', 'time': DateTime.now().toString()};
    _messages.value = [..._messages.value, newMessage];
    _controller.clear();
    setState(() {
      _isLoading = true;
    });

    // Send message to Gemini API
    final response = await _getGeminiResponse(message);
    newMessage['model'] = response;
    _messages.value = [..._messages.value];

    // Save to Firestore
    await _firestore.collection('bot_messages').doc(widget.userEmail).set({
      'email': widget.userEmail,
      'messages': _messages.value,
    });

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _getGeminiResponse(String message) async {
    try {
      final Map<String, dynamic> requestLegalBody = {
      "contents": [
            {
                "parts": [
                    {
                        "text": Utilities.processPromptForSupportChat(message),
                    }
                ]
            }
        ]
      };

      String legalPromptResponse = '';

      final responseLegal = await http.post(
        Uri.parse(Secret.geminiApiUrl),
        headers: {"Content-Type": "application/json"}, // Optional headers
        body: jsonEncode(requestLegalBody), // Encoding data
      );

      if(responseLegal.statusCode == 200 || responseLegal.statusCode == 201) {
        Map<String, dynamic> responseDecoded = jsonDecode(responseLegal.body);
        legalPromptResponse = responseDecoded["candidates"][0]["content"]["parts"][0]["text"];
      }

      else {
        legalPromptResponse = "NA";
      }

      return 'Q : $message\n\nA : $legalPromptResponse';
    
    }

    catch(error) {
      return 'Q : $message\n\nA : Sorry, Some error occured. Please try again to reach for more network or either restart your device.';
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Support')),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _messages,
              builder: (context, messages, child) {
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg['model'].isEmpty;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(msg[isUser ? 'user' : 'model']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading) 
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}