import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haven_net/features/app_invoke_record/view/app_invoke_record.dart';
import 'package:haven_net/main.dart';
import 'package:haven_net/secret.dart';
import 'package:haven_net/utils/utilities.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeechScreen extends StatefulWidget {
  final List<dynamic> eventsList;
  const SpeechScreen({super.key, required this.eventsList});
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking.";
  String _responseText = "";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) async {

            EasyDebounce.debounce(
                'my-debouncer',                 
                const Duration(milliseconds: 500),
                () async {
                    try {
                      final Map<String, dynamic> requestBody = {
                          "contents": [
                              {
                                  "parts": [
                                      {
                                          "text": Utilities.processBullyPrompt(val.recognizedWords),
                                      }
                                  ]
                              }
                          ]
                      };

                      final response = await http.post(
                        Uri.parse(Secret.geminiApiUrl),
                        headers: {"Content-Type": "application/json"}, // Optional headers
                        body: jsonEncode(requestBody), // Encoding data
                      );

                      if (response.statusCode == 201 || response.statusCode == 200) {
                        Map<String, dynamic> responseDecoded = jsonDecode(response.body);
                        _responseText = responseDecoded["candidates"][0]["content"]["parts"][0]["text"];
                        if(_responseText.contains("yes") || _responseText.contains("Yes") || _responseText.contains("YES")) {
                          final childDataSnapshot = await FirebaseFirestore.instance.collection('registrations').where("user_credential", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
                          final childData = childDataSnapshot.docs.map((doc) => doc.data()).toList();

                          print("father email : ${childData[0]["father_email"]}");
                          
                          final emailDataSnapshot = await FirebaseFirestore.instance.collection('fcmtokens').where("email", isEqualTo: childData[0]["father_email"]).get();
                          final fcmTokenData = emailDataSnapshot.docs.map((doc) => doc.data()).toList();

                          final fcmToken = fcmTokenData[0]["token"];
                          print("fcm token : $fcmToken");

                          final fcmServerKeyList = await FirebaseFirestore.instance.collection('app_secret').get();
                          final fcmServerKeyData = fcmServerKeyList.docs.map((doc) => doc.data()).toList();
                          final fcmAuthorizationKey = fcmServerKeyData[0]["fcmKey"];
                          
                          print("fcm authorization : $fcmAuthorizationKey");

                          try {
                            final responseMessage = await http.post(
                              Uri.parse(Secret.firebaseMessagingUrl),
                              headers: <String, String>{
                                'Content-Type': 'application/json',
                                'Authorization': "Bearer $fcmAuthorizationKey",
                              },
                              body: jsonEncode(
                                <String, dynamic>{
                                  "message": {
                                    "token": fcmToken,
                                    "notification": {
                                      "title": "Haven Net",
                                      "body": "Your child is being bullied."
                                    }
                                  }
                                } 
                              ),
                            );

                            if(responseMessage.statusCode == 200 || responseMessage.statusCode == 201) {
                              print('Push notification sent successfully');
                            } 
                            
                            else {
                              print('Error sending push notification: ${responseMessage.body}, ${responseMessage.statusCode}');
                            }
                          } 
                          
                          catch (e) {
                            print('Exception sending push notification: $e');
                          }
                        }

                        else {
                          print("Your child is not bullied");
                        }

                        print("Success: ${response.body}");
                      } 
                      
                      else {
                        print("Failed with status: ${response.statusCode}");
                      }
                    } 
                    
                    catch (e) {
                      print("Error: $e");
                    }


                    setState(() {
                      _text = _responseText;
                      if (val.hasConfidenceRating && val.confidence > 0) {
                        _confidence = val.confidence;
                      }
                      }
                    );
                },
              );
            } 
        );
      }
    } 
    
    else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Haven Net',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          GestureDetector(
            onTap: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => AppInvokeRecordPage(events: widget.eventsList)
                ),
              );
            },
            child: const Icon(
              Icons.app_registration,
              color: Colors.white,
            ),
          ),
          
        ],
      ),
      body: Column(
          children: [
            Text(
              'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 24.0),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _text,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}