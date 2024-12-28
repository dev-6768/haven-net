import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ParentRegistrationForm extends StatefulWidget {
  const ParentRegistrationForm({super.key});
  @override
  _ParentRegistrationFormState createState() => _ParentRegistrationFormState();
}

class _ParentRegistrationFormState extends State<ParentRegistrationForm> {
  final _formKeyPage2 = GlobalKey<FormBuilderState>();
  final PageController _pageController = PageController();
  bool isLoading = false;
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration Form"),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPage1(),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKeyPage2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Parent Details",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMandatoryField('father_name', 'Name of the Father'),
              const SizedBox(height: 10),
              _buildMandatoryField('mother_name', 'Name of the Mother'),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'father_contact',
                "Father's Contact No",
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'mother_contact',
                "Mother's Contact No",
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'father_email',
                "Father's Email",
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'mother_email',
                "Mother's Email",
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _buildOptionalField('father_designation', "Father's Designation"),
              const SizedBox(height: 10),
              _buildOptionalField('mother_designation', "Mother's Designation"),
              const SizedBox(height: 10),
              _buildOptionalField(
                  'father_office_address', "Father's Office Address"),

              const SizedBox(height: 10),
              _buildOptionalField(
                  'mother_office_address', "Mother's Office Address"),
              
              const SizedBox(height: 10),
              _buildMandatoryField('home_address', 'Home Address'),

              const SizedBox(height: 10),
              _buildMandatoryPasswordField(
                "password", 
                "Password"
              ),
              const SizedBox(height: 10),
              
              _buildMandatoryPasswordField(
                'confirm_password',
                'Confirm Password',
                matchField: 'password',
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: isLoading 
                  ? const Center(
                    child: CircularProgressIndicator()
                  )
                  : const Text("Submit") 
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMandatoryField(String name, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: inputType,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
    );
  }

  Widget _buildOptionalField(String name, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: inputType,
      ),
    );
  }

  Widget _buildMandatoryPasswordField(String name, String label,
      {String? matchField}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: true,
        validator: matchField != null
            ? FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                (val) {
                  if (_formKeyPage2.currentState?.fields[matchField]?.value != val) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ])
            : FormBuilderValidators.required(),
      ),
    );
  }

  Future<void> _submitForm() async {
    bool? savedValue = _formKeyPage2.currentState?.saveAndValidate();
    savedValue ??= false;

    if (savedValue) {
      // final page1Data = _formKeyPage1.currentState?.value;
      // final page2Data = _formKeyPage2.currentState?.value;
      _formData.addAll(_formKeyPage2.currentState!.value);
      setState(() {
        isLoading = true;
      });

      try {
        final email = _formData['father_email'];
        final password = _formData['password'];
        final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

        // Save form data to Firestore
        Map<String, dynamic> firestoreData = {};
        firestoreData.addAll(_formData);
        firestoreData["user_credential"] = userCredential.user?.uid;
        firestoreData["fcmToken"] = await FirebaseMessaging.instance.getToken();
        firestoreData["user_type"] = "parent";

        Map<String, String> fcmTokenData = {
          "email": _formData["father_email"],
          "token": firestoreData["fcmToken"]
        };

        await FirebaseFirestore.instance.collection('registrations').add(firestoreData);
        await FirebaseFirestore.instance.collection('fcmtokens').add(fcmTokenData);
        _showSnackbar("Registration successful!");

        setState(() {
          isLoading = false;
        });
      } 
      
      catch (error) {
        setState(() {
          isLoading = false;
        });
        _showSnackbar("Error: $error");
      }
    } 
    
    else {
      _showSnackbar("Please fill all mandatory fields correctly.");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
