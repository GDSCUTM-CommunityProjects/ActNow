import 'package:actnow/pages/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final Function(User?) onSignIn;

  const LoginPage({Key? key, required this.onSignIn}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Required for form validator

  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  loginEmailPass() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCreds = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _userEmail.text, password: _userPassword.text);

        if (userCreds.user != null && !userCreds.user!.emailVerified) {
          showError("Please verify your email", "VERIFY");
        } else {
          widget.onSignIn(userCreds.user);
        }
      } on FirebaseAuthException catch (e) {
        showError(e.message, "ERROR");
      }
    }
  }

  showError(String? errormessage, String? title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title!),
            content: Text(errormessage!),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double heightVariable = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
            height: heightVariable,
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(
                                top: heightVariable / 8,
                                bottom: heightVariable / 15),
                            child: Stack(
                              children: const <Widget>[
                                Image(
                                  image: AssetImage('assets/Logo.png'),
                                  height: 122,
                                  width: 139.73,
                                ),
                              ],
                            )),
                        Container(
                            padding: const EdgeInsets.only(
                                top: 30.0, left: 20.0, right: 20.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      validator: (input) {
                                        if (input == null || input.isEmpty) {
                                          return "Enter an email";
                                        }
                                        bool validEmail = RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(input);
                                        if (!validEmail) {
                                          return "Enter a valid email";
                                        }
                                      },
                                      controller: _userEmail,
                                      decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Email',
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 10.0),
                                    TextFormField(
                                      validator: (input) {
                                        if (input == null || input.isEmpty) {
                                          return "Enter a password";
                                        }
                                      },
                                      controller: _userPassword,
                                      decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Password',
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          border: OutlineInputBorder()),
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 2.0),
                                    Container(
                                      alignment: const Alignment(1.0, 0.0),
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: InkWell(
                                        onTap: () {
                                          Route route = MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordPage());
                                          Navigator.push(context, route);
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    SizedBox(
                                      width: 180,
                                      height: 40.0,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        shadowColor: Colors.grey,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            loginEmailPass();
                                          },
                                          child: const Center(
                                            child: Text(
                                              'Log In',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    SizedBox(
                                      width: 180,
                                      height: 40.0,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        shadowColor: Colors.grey,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              side: const BorderSide(
                                                  color: Colors.blue)),
                                          onPressed: () {
                                            Route route = MaterialPageRoute(
                                                builder: (context) =>
                                                    const SignupPage());
                                            Navigator.push(context, route);
                                          },
                                          child: const Center(
                                            child: Text(
                                              'Sign Up',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))),
                        const SizedBox(height: 60.0),
                        const Text(
                          'Or connect using',
                        ),
                        const SizedBox(height: 20.0),
                        SignInButtonBuilder(
                          width: 180,
                          height: 40.0,
                          text: 'Google',
                          textColor: const Color.fromRGBO(0, 0, 0, 0.54),
                          image: Container(
                            margin:
                                const EdgeInsets.fromLTRB(26.0, 0.0, 10.0, 0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: const Image(
                                image: NetworkImage(
                                    'https://developers.google.com/identity/images/g-logo.png'),
                                height: 20.0,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            await handleGoogleSignIn();
                          },
                          backgroundColor: const Color(0xFFFFFFFF),
                        ),
                      ],
                    )))));
  }

  Future<void> handleGoogleSignIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User? user = (await _auth.signInWithCredential(credential)).user;

    DocumentReference ref = firestore.collection('users').doc(user!.uid);

    final doc = await ref.get();

    // if the user is not in the database, add them.
    // Otherwise, do not update their info
    if (!doc.exists) {
      ref.set({
        'userid': user.uid,
        'username': user.email,
        'firstname': user.displayName,
        "isSwitched": false,
        'lastname': "",
        'profile_picture': user.photoURL,
      });
    }

    widget.onSignIn(user);
  }

  Future<Null> handleFacebookSignIn() async {}
}
