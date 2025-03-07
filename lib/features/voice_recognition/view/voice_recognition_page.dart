import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haven_net/features/app_invoke_record/view/app_invoke_record.dart';
import 'package:haven_net/features/first_screen/view/first_screen.dart';
import 'package:haven_net/main.dart';
import 'package:haven_net/secret.dart';
import 'package:haven_net/utils/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String recognizedWords = "";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print("onStatus : $val");
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          listenMode: stt.ListenMode.dictation,
          onResult: (val) async {
            EasyDebounce.debounce(
                'my-debouncer',                 
                const Duration(milliseconds: 500),
                () async {
                    try {
                      recognizedWords = val.recognizedWords;
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
                        recognizedWords = val.recognizedWords;
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

  Future<void> sendComplaintToParent() async {

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending complaint...."),));
      final childDataSnapshot = await FirebaseFirestore.instance.collection('registrations').where("user_credential", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
      final childData = childDataSnapshot.docs.map((doc) => doc.data()).toList();


      final Map<String, dynamic> requestLegalBody = {
        "contents": [
            {
                "parts": [
                    {
                        "text": Utilities.processLegalReprecussionsPrompt(recognizedWords),
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

      if(_responseText.contains("YES") || _responseText.contains("Yes") || _responseText.contains("yes")) {
        final getCurrentVictimLocation = await Utilities().getFullLocation();
        await FirebaseFirestore.instance.collection('complaints').add({
          "victim_name" : childData[0]["child_name"],
          "victim_grade" : childData[0]["child_grade"],
          "victim_email" : childData[0]["child_email"],
          "victim_contact" : childData[0]["child_contact"],
          "victim_father_email" : childData[0]["father_email"],
          "victim_mother_email" : childData[0]["mother_email"],
          "victim_credentials" : childData[0]["user_credential"],
          "complaint_subject" : "Your child (${childData[0]["child_name"]}) is being bullied.",
          "complaint_body" : _responseText,
          "complaint_time" : DateTime.now(),
          "legal_reprecussions" : legalPromptResponse,
          "victim_father_contact" : childData[0]["father_contact"],
          "victim_mother_contact" : childData[0]["mother_contact"],
          "victim_location" : getCurrentVictimLocation,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Complaint sent."),));
      }

      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to sent complaint."),));
        print("This is not a case of bullying");
      }

    }

    catch(err) {

    }
  }

  @override
  void dispose() {
    super.dispose();
    FirebaseAuth.instance.signOut();
  }

  Future<void> logoutParentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_email', "");
    await prefs.setString('login_password', "");
    await prefs.setString('login_user_type', "");

    FirebaseAuth.instance.signOut();

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FirstScreen())
    );
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
          TextButton(onPressed: () async {
              await logoutParentUser();
            }, 
            child: const Text("Logout"),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
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

          const SizedBox(width: 10),
          
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
                    child: Column(
                      children: [
                        Text(
                          "$_text\n\n${(_text.contains("YES") || _text.contains("Yes") || _text.contains("yes")) ? "We have sent your complaint to your parents." : "No case of bullying detected"}",
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Visibility(
                          visible: (_text.contains("YES") || _text.contains("Yes") || _text.contains("yes")),
                          child: Center(
                            child: ElevatedButton(onPressed: () async {
                              await sendComplaintToParent();
                            }, child: const Text("Send Complaint"))
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _listen();
        },
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}