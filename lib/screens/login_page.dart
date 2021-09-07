import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:runo_notes/networking/encryption.dart';
import 'package:runo_notes/networking/firebase_storage.dart';
import 'package:runo_notes/screens/home_screen.dart';
import 'package:runo_notes/screens/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late String pass;
  late Map<String, dynamic> data;
  late List<Map<String, dynamic>> credentials;

  @override
  void initState() {
    super.initState();
    credentials = <Map<String, dynamic>>[];
    pass = '';
  }

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                "LogIn",
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
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (text) {
                            if (text!.length != 10) {
                              return "Please enter valid phone number";
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(fontSize: 15.0),
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
                          validator: (text) {},
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
                        ElevatedButton(
                          onPressed: () async {
                            var credential = credentials.toSet().toList();
                            var isValid = false;
                            for (int i = 0; i < data.length; i++) {
                              if (credential[i]['mobile'] ==
                                  _phoneController.text) {
                                pass = EncryptionDecryption.decryption(
                                    credential[i]['password']);
                                // print("Pass: ${pass}");
                                if (pass == _passwordController.text) {
                                  isValid = true;
                                  SharedPreferences pref =
                                      await SharedPreferences.getInstance();
                                  pref.setBool('login', true);
                                  FirebaseStorage()
                                      .addDataToSF('id', credential[i]['id']);

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen(id: credential[i]['id']),
                                    ),
                                  );
                                  setState(() {});
                                }
                              } else {
                                pass = '';
                              }
                            }

                            if (!isValid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mobile or Password incorrect'),
                                ),
                              );
                            }
                          },
                          child: Text('LogIn'),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "New user? ",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "SignUp here",
                                style: TextStyle(
                                  fontSize: 14,
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseStorage().usersStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          data = document.data()! as Map<String, dynamic>;
                          credentials.add(data);

                          /*if (data['mobile'] == _phoneController.text) {
                          pass =
                              EncryptionDecryption.decryption(data['password']);
                        }*/

                          return SizedBox();
                        }).toList(),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
