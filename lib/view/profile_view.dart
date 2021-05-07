import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/model/user_model.dart';

class ProfileView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool submitting = false;
  bool editing = false;
  List<Widget> actions = [];

  final usernameRegexp = RegExp(r"^[a-zA-Z0-9]+([_@#&-]?[a-zA-Z0-9 ])*$");
  final nameRegexp = RegExp(r"^([^0-9{}\\/()\]\[]*)$");

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = "username";
    _nameController.text = "Name Surname";
    _emailController.text = "email@domain.com";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

/*  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Username is mandatory";
    }
    int size = value.length;
    if (size < 6 || size > 30) {
      return "Username must be between 6 and 30 characters";
    }
    if (!usernameRegexp.hasMatch(value)) {
      return "Invalid username";
    }
    return null;
  }*/

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is mandatory";
    }
    int size = value.length;
    if (size > 60) {
      return "Names should be 60 characters or less";
    }
    if (!nameRegexp.hasMatch(value)) {
      return "Invalid name";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is mandatory";
    }
    if (!EmailValidator.validate(value)) {
      return "Invalid email";
    }
    return null;
  }

  void _editValue(
      TextEditingController ctrl, String? Function(String?) validator) async {
    GlobalKey<FormState> key = new GlobalKey<FormState>();
    String? result;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Enter a new value"),
              content: Form(
                key: key,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: ctrl.text,
                  validator: validator,
                  onSaved: (val) {
                    Navigator.pop(context, val);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL"),
                ),
                TextButton(
                    onPressed: () {
                      var form = key.currentState!;
                      if (form.validate()) {
                        form.save();
                      }
                    },
                    child: Text('SAVE')),
              ],
            )).then((value) => result = value);

    if (result != null) {
      setState(() {
        actions = [
          TextButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white)),
              onPressed: _submitChanges,
              child: Text("SAVE CHANGES")),
        ];
        ctrl.text = result!;
      });
    }
  }

  void _submitChanges() async {
    setState(() {
      submitting = true;
      actions = [];
    });

    // TODO - submit
    setState(() {
      submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 15,
    );
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text("Profile Info"),
          actions: actions,
        ),
        SliverPadding(
          padding: EdgeInsets.all(20),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Center(
              heightFactor: 4,
              child: Icon(Icons.person_sharp),
            ),
            Consumer<UserModel>(builder: (context, model, child) {
              if (model.userStatus == UserStatus.AUTH) {
                AuthenticatedUser user = model.user as AuthenticatedUser;
                _usernameController.text = user.username;
                _nameController.text = user.name;
                _emailController.text = user.email;
              } else {
                return Center(
                  child: Text(
                    'Logged as Local User',
                    textScaleFactor: 1.3,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _usernameController,
                    enabled: true,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.person_outline),
                      labelText: "Username",
                    ),
                  ),
                  sizedBox,
                  TextField(
                    controller: _nameController,
                    enabled: true,
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.person),
                        labelText: "Name",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editValue(_nameController, _validateName);
                          },
                        )),
                  ),
                  sizedBox,
                  TextField(
                    controller: _emailController,
                    enabled: true,
                    readOnly: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.email),
                        labelText: "Email",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editValue(_emailController, _validateEmail);
                          },
                        )),
                  ),
                  sizedBox,
                  Visibility(
                      visible: submitting,
                      child: SizedBox(
                        height: 90,
                        child: Center(child: CircularProgressIndicator()),
                      )),
                ],
              );
            }),
            Divider(
              height: 30,
              thickness: 3,
            ),
            Consumer<UserModel>(builder: (context, model, child) {
              switch (model.userStatus) {
                case UserStatus.AUTH:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        child: Text(
                          'LOGOUT',
                          textScaleFactor: 1.2,
                        ),
                        onPressed: () => _showLogoutDialog(context),
                      ),
                      Divider(
                        height: 30,
                        thickness: 3,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        child: Text(
                          "DELETE ACCOUNT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textScaleFactor: 1.2,
                        ),
                        onPressed: () {
                          // TODO - delete account
                        },
                      ),
                    ],
                  );
                case UserStatus.LOCAL:
                  return ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/welcome'),
                      child: Text('UPGRADE ACCOUNT'));
                default:
                  return Center();
              }
            }),
          ])),
        )
      ],
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text("Logout"),
            content: SingleChildScrollView(
              child: Text('Are you sure you want to logout?\n'
                  'All your un-synced modifications will be discarded.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                  onPressed: () async {
                    await Provider.of<UserModel>(context, listen: false)
                        .logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/welcome', (_) => false);
                  },
                  child: Text('YES, LOG ME OUT!'))
            ],
          ));
}
