import 'package:flutter/material.dart';
import 'package:runo_notes/model/SignUp.dart';
import 'package:runo_notes/networking/encryption.dart';
import 'package:runo_notes/networking/firebase_storage.dart';
import 'package:runo_notes/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                "SignUp",
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 50,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Container(
                    //margin: EdgeInsets.only(bottom: keyboardHeight),
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Username should not be empty";
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.person),
                          ),
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (text) {
                            if (text!.length != 10) {
                              return "Please enter valid mobile number";
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.phone_iphone),
                          ),
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          obscuringCharacter: '•',
                          validator: (text) {
                            if (text!.length <= 6) {
                              return "Password length should be more than 6";
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(fontSize: 16.0),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    var encryptPass;
                                    isLoading = true;
                                    encryptPass =
                                        EncryptionDecryption.encryption(
                                            _passwordController.text);
                                    var id = DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString();

                                    SignUp signUp = SignUp(
                                      name: _nameController.text,
                                      mobile: _phoneController.text,
                                      password: encryptPass.base64,
                                      id: id,
                                    );
                                    FirebaseStorage().addUser(signUp);
                                    FirebaseStorage().addDataToSF('id', id);
                                    FirebaseStorage()
                                        .addDataToSF('noteRef', 'null');
                                    isLoading = false;
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    pref.setBool('login', true);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen(id: id),
                                      ),
                                    );
                                    setState(() {});
                                  }
                                },
                                child: Text('SignUp'),
                              ),
                        const SizedBox(
                          height: 25,
                        ),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Already register? ",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "LogIn here",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
