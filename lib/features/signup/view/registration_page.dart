import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKeyPage1 = GlobalKey<FormBuilderState>();
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
          _buildPage2(),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKeyPage1,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Child Details",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _buildMandatoryField('child_name', 'Name of the Child'),
              const SizedBox(height: 10),
              _buildMandatoryField('child_grade', 'Grade of the Child'),
              const SizedBox(height: 10),
              _buildMandatoryField('school_name', 'School Name of the Child'),
              const SizedBox(height: 10),
              _buildMandatoryField('school_address', 'Address of the School'),
              const SizedBox(height: 10),
              _buildMandatoryField('home_address', 'Address of the Home'),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'child_contact',
                'Contact No of the Child',
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _buildMandatoryField(
                'child_email',
                'Email ID of the Child',
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _buildMandatoryPasswordField('password', 'Password'),
              const SizedBox(height: 10),
              _buildMandatoryPasswordField(
                'confirm_password',
                'Confirm Password',
                matchField: 'password',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  bool? savedValue = _formKeyPage1.currentState?.saveAndValidate();
                  savedValue ??= false;
                  if (savedValue) {
                    _formData.addAll(_formKeyPage1.currentState!.value);
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } 
                  
                  else {
                    _showSnackbar("Please fill all mandatory fields correctly.");
                  }
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage2() {
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: const Text("Back"),
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
                  if (_formKeyPage1.currentState?.fields[matchField]?.value !=
                      val) {
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
        final email = _formData['child_email'];
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
        firestoreData["user_type"] = "child";
        await FirebaseFirestore.instance.collection('registrations').add(firestoreData);
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
