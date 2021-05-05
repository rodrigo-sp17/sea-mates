import 'dart:io';

import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String username = "";
  String password = "";
  bool isLoading = false;

  void _submit() async {
    setState(() {
      isLoading = true;
    });

    var result;

    sleep(Duration(seconds: 2));
/*    if (result.statusCode == 200) {

    } else if (result.statusCode == 401 || result.statusCode == 403){
      // wrong login

    }*/

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                icon: const Icon(Icons.person_outline),
                labelText: 'Email or Username'),
            autofillHints: [
              AutofillHints.username,
            ],
            onSaved: (value) {
              username = value;
            },
          ),
          TextFormField(
            textInputAction: TextInputAction.next,
            obscureText: true,
            decoration: InputDecoration(
              icon: const Icon(Icons.security),
              labelText: 'Password',
            ),
            autofillHints: [AutofillHints.password],
            onSaved: (value) {
              password = value;
            },
          ),
          SizedBox(
            height: 30,
          ),
          Visibility(
              visible: isLoading,
              child: LinearProgressIndicator(
                value: null,
              )),
          ElevatedButton(
              style: ButtonStyle(), onPressed: _submit, child: Text('LOGIN'))
        ],
      ),
    ));
  }

  void _showDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(message),
            ));
  }
}
