import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/model/user_model.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String username = "";
  String password = "";

  void _submit() async {
    _formKey.currentState!.save();
    log(username);
    log(password);

    var result = Provider.of<UserModel>(context, listen: false)
        .login(username, password);

    await result.then(
      (success) {
        if (success) {
          Navigator.pushNamed(context, '/home');
        } else {
          _showFailureDialog("Incorrect username/email and/or password");
        }
      },
    ).catchError((e) {
      _showFailureDialog(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
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
                  username = value!;
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
                  password = value!;
                },
              ),
              SizedBox(
                height: 30,
              ),
              Consumer<UserModel>(
                builder: (context, model, child) {
                  if (model.loaded) {
                    return ElevatedButton(
                        style: ButtonStyle(),
                        onPressed: _submit,
                        child: Text('LOGIN'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ));
  }

  void _showFailureDialog(String failedMessage) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Failed to login"),
              content: Text(failedMessage),
            ));
  }
}
