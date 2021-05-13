import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/view/home_page.dart';
import 'package:sea_mates/view/welcome_page.dart';

/// Provides a initial view to show the proper initial page
///
/// It is an app level splash screen, not a system level one
class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, model, child) {
      if (!model.loaded) {
        return Scaffold(
          body: Container(
            child: Center(child: Text('logo placeholder')),
          ),
        );
      } else if (model.userStatus != UserStatus.ANONYMOUS) {
        return HomePage();
      } else {
        return WelcomePage();
      }
    });
  }
}
