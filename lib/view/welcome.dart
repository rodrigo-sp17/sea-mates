import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sea_mates/view/home.dart';
import 'package:sea_mates/view/login.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(
            child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: [
            SizedBox(
              height: 220,
              child: Text('Logo placeholder'),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  // retrieve info, send to endpoint to process
                  // go to socialSignup
                  // or save token
                },
                child: Text("Continue with Facebook")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                child: Text("Login")),
            Divider(
              height: 20,
              thickness: 2,
            ),
            ElevatedButton(
                onPressed: () {
                  // push signup
                },
                child: Text("Signup")),
            Divider(
              height: 20,
              thickness: 2,
            ),
            ElevatedButton(
                onPressed: () {
                  // notify user about later sync possibilities
                  // notify about friends not available while offline
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text("Entering as Anonymous"),
                            content: SingleChildScrollView(
                              child: Text(
                                  'You are now going in anonymous mode.\n\n'
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
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                  },
                                  child: Text('Got ya!'))
                            ],
                          ));
                  // push anonymous
                },
                child: Text("Continue offline"))
          ],
        )));
  }
}
