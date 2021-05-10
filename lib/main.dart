import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sea_mates/data/auth_user.dart';
import 'package:sea_mates/data/shift.dart';
import 'package:sea_mates/data/sync_status.dart';
import 'package:sea_mates/model/user_model.dart';
import 'package:sea_mates/repository/impl/shift_hive_repository.dart';
import 'package:sea_mates/repository/impl/shift_web_client.dart';
import 'package:sea_mates/repository/impl/user_hive_repo.dart';
import 'package:sea_mates/view/home.dart';
import 'package:sea_mates/view/login.dart';
import 'package:sea_mates/view/signup_page.dart';
import 'package:sea_mates/view/welcome.dart';

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
  userModel.update(shiftListModel);

  runApp(MyApp(userModel, shiftListModel));
}

class MyApp extends StatelessWidget {
  MyApp(this.userModel, this.shiftListModel);
  final UserModel userModel;
  final ShiftListModel shiftListModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: userModel),
          ChangeNotifierProvider.value(value: shiftListModel)
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
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
              '/login': (context) => Login(),
              '/signup': (context) => SignupPage(),
            }));
  }
}
