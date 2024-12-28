import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:haven_net/features/parent_home_page/view/parent_home_page.dart';

class ParentLoginPage extends StatefulWidget {
  const ParentLoginPage({super.key});
  @override
  _ParentLoginPageState createState() => _ParentLoginPageState();
}

class _ParentLoginPageState extends State<ParentLoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email Field
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 20),

                // Password Field
                FormBuilderTextField(
                  name: 'password',
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(6,
                        errorText: "Password must be at least 6 characters"),
                  ]),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: isLoading 
                    ? const Center(
                      child: CircularProgressIndicator(),
                    )
                    : const Text("Login")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      final email = formData?['email'];
      final password = formData?['password'];

      try {
        setState(() {
          isLoading = true;
        });
        final parentUsers = await FirebaseFirestore.instance.collection("registrations").where("father_email", isEqualTo: email).where("password", isEqualTo: password).where("user_type", isEqualTo: "parent").get();
        final parentUserList = parentUsers.docs.map((doc) => doc.data()).toList();
        if(parentUserList.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ParentsHomePage()),
          );

          _showSnackbar("Login Successful");
        }

        else {
          _showSnackbar("Login Failed");
        }

        setState(() {
          isLoading = false;
        });
      } 
      
      catch (error) {
        _showSnackbar("Login failed: $error");
      }
    } 
    
    else {
      _showSnackbar("Please fill all fields correctly.");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}