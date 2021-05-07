import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/model/shift_list_model.dart';
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
  bool hidePassword = true;

  void _togglePasswordVisible() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void _submit() async {
    _formKey.currentState!.save();

    var userProvider = Provider.of<UserModel>(context, listen: false);
    var initialStatus = userProvider.userStatus;

    var result = userProvider.login(username, password);
    await result.then(
      (success) async {
        if (success) {
          if (initialStatus == UserStatus.LOCAL) {
            await _showUpgradeDialog();
          }
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        } else {
          _showFailureDialog(
              "Login failed", "Incorrect username/email and/or password");
        }
      },
    ).catchError((e) {
      _showFailureDialog("Oops...", "Something went wrong!\n");
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
                obscureText: hidePassword,
                decoration: InputDecoration(
                    icon: const Icon(Icons.security),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: hidePassword
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                      onPressed: _togglePasswordVisible,
                    )),
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

  Future<void> _showUpgradeDialog() {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Upgrade Successful"),
              content: Text(
                  "Do you want to synchronize your local data with your online account?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('CANCEL'),
                ),
                TextButton(
                    onPressed: () async {
                      await Provider.of<ShiftListModel>(context, listen: false)
                          .syncShifts()
                          .catchError((e) {
                        log(e);
                        _showFailureDialog("Sync failed!",
                            "Sorry, we could not sync your data :(");
                      });
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (_) => false);
                    },
                    child: Text('YES'))
              ],
            ));
  }

  void _showFailureDialog(String title, String failedMessage) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(failedMessage),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }
}
