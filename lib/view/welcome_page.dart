import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/api_utils.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Scrollbar(
              child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: [
              SizedBox(
                height: 220,
                child: Text('Logo placeholder'),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(height: 45),
                child: SignInButton(Buttons.Facebook,
                    text: 'Continue with Facebook',
                    onPressed: () => Navigator.pushNamed(context, '/oauth2')),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Login with email")),
              Divider(
                height: 20,
                thickness: 0,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text("Signup")),
              Divider(
                height: 20,
                thickness: 0,
              ),
              Consumer<UserModel>(builder: (context, model, child) {
                switch (model.userStatus) {
                  case UserStatus.ANONYMOUS:
                    return ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey)),
                        onPressed: () {
                          _showLocalUserDialog(context);
                        },
                        child: Text("Continue offline"));
                  case UserStatus.LOCAL:
                    return ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey)),
                        onPressed: () => Navigator.pushNamed(context, '/home'),
                        child: Text("Remain in local mode"));
                  case UserStatus.AUTH:
                    return ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey)),
                      onPressed: () => _showLogoutDialog(context),
                      child: Text("Logout"),
                    );
                  default:
                    throw AssertionError("Unrecognized user status");
                }
              }),
              SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () => launch(
                    Uri.https(ApiUtils.API_BASE, '/recovery').toString()),
                child: Text('Forgot your password?'),
              )
            ],
          ))),
    );
  }
}

void _showLocalUserDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text("Entering in Local mode"),
            content: SingleChildScrollView(
              child: Text('You are now going in local mode.\n\n'
                  'In this mode, you will not be able to:\n'
                  '- Add friends\n'
                  '- View friends shifts\n'
                  '- Invite friends to events\n'
                  '- Sync with the cloud\n\n'
                  'However, don\'t worry!\n'
                  'You can add an account later and sync your shifts! :)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('CANCEL'),
              ),
              TextButton(
                  onPressed: () async {
                    var result =
                        await Provider.of<UserModel>(context, listen: false)
                            .loginAsLocal();
                    if (result)
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (_) => false);
                  },
                  child: Text('GOT IT!'))
            ],
          ));
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
                  },
                  child: Text('YES, LOG ME OUT!'))
            ],
          ));
}
