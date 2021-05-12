import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/friend_list_model.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/impl/friends_web_client.dart';
import 'package:sea_mates/repository/impl/shift_hive_repository.dart';
import 'package:sea_mates/repository/impl/shift_web_client.dart';
import 'package:sea_mates/repository/impl/user_hive_repo.dart';
import 'package:sea_mates/view/home.dart';
import 'package:sea_mates/view/login_page.dart';
import 'package:sea_mates/view/oauth_view.dart';
import 'package:sea_mates/view/signup_page.dart';
import 'package:sea_mates/view/social_signup_page.dart';
import 'package:sea_mates/view/welcome_page.dart';

import 'model/shift_list_model.dart';

void main() async {
  await Hive.initFlutter("sea_mates");
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(SyncStatusAdapter());
  Hive.registerAdapter(AuthenticatedUserAdapter());

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  var userModel = UserModel(UserHiveRepository());
  var shiftListModel = ShiftListModel(ShiftWebClient(), ShiftHiveRepository());
  shiftListModel.update(userModel);
  var friendListModel = FriendListModel(FriendsWebClient());
  friendListModel.update(userModel);
  userModel.update(shiftListModel, friendListModel);

  runApp(MyApp(userModel, shiftListModel, friendListModel));
}

class MyApp extends StatelessWidget {
  MyApp(this.userModel, this.shiftListModel, this.friendListModel);
  final UserModel userModel;
  final ShiftListModel shiftListModel;
  final FriendListModel friendListModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userModel),
          ChangeNotifierProvider.value(value: shiftListModel),
          ChangeNotifierProvider.value(value: friendListModel)
        ],
        child: MaterialApp(
            navigatorKey: userModel.navigatorKey,
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.indigo,
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(Size.fromHeight(45)),
                        textStyle: MaterialStateProperty.all(TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))))),
            home: Consumer<UserModel>(
              builder: (context, model, child) {
                if (model.userStatus != UserStatus.ANONYMOUS) {
                  return HomePage();
                } else {
                  return WelcomePage();
                }
              },
            ),
            routes: {
              '/welcome': (context) => WelcomePage(),
              '/home': (context) => HomePage(),
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignupPage(),
              '/socialSignup': (context) => SocialSignupPage(),
              '/oauth2': (context) => OAuthView(),
            }));
  }
}
