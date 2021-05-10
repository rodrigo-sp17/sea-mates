import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/user_request.dart';
import 'package:sea_mates/exception/rest_exceptions.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/validators.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupForm(),
    );
  }
}

class SignupForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserRequest request = UserRequest.empty();

  bool hidePassword = true;

  void _togglePasswordVisible() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void _submit() async {
    var form = _formKey.currentState!;
    if (!form.validate()) {
      return;
    }

    form.save();
    var userModel = Provider.of<UserModel>(context, listen: false);

    var result = userModel.signup(request);
    await result.then(
      (success) async {
        if (success) {
          await _showDialog(
              "Signup success!", "Please login to confirm your registration");
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          _showDialog("Unauthorized", "You are not authorized to signup");
        }
      },
    ).catchError((e) {
      if (e is RestException) {
        _showDialog("Signup failed", e.message);
      }
    });
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is mandatory';
    }
    if (value != request.password) {
      return 'Confirm password does not match password';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scrollbar(
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              SizedBox(
                height: 150,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    icon: const Icon(Icons.person_outline), labelText: 'Name'),
                autofillHints: [
                  AutofillHints.name,
                ],
                validator: Validators.validateName,
                onSaved: (value) {
                  request.name = value!;
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    icon: const Icon(Icons.person), labelText: 'Username'),
                autofillHints: [
                  AutofillHints.username,
                ],
                validator: Validators.validateUsername,
                onSaved: (value) {
                  request.username = value!;
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    icon: const Icon(Icons.person_outline), labelText: 'Email'),
                autofillHints: [
                  AutofillHints.email,
                ],
                validator: Validators.validateEmail,
                onSaved: (value) {
                  request.email = value!;
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.visiblePassword,
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
                validator: Validators.validatePassword,
                onChanged: (value) {
                  request.password = value;
                },
                onFieldSubmitted: (value) {
                  request.password = value;
                },
                onSaved: (value) {
                  request.password = value!;
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  icon: Icon(Icons.check),
                  labelText: 'Confirm Password',
                ),
                autofillHints: [AutofillHints.password],
                validator: _validateConfirmPassword,
                onSaved: (value) {
                  request.confirmPassword = value!;
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
                        child: Text(
                          'SIGNUP',
                          textScaleFactor: 1.2,
                        ));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ));
  }

  Future _showDialog(String title, String failedMessage) {
    return showDialog(
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
