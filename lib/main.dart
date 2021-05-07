import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:sea_mates/view/welcome.dart';

import 'model/shift_list_model.dart';

void main() async {
  await Hive.initFlutter("sea_mates");
  Hive.registerAdapter(ShiftAdapter());
  Hive.registerAdapter(SyncStatusAdapter());
  Hive.registerAdapter(AuthenticatedUserAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserModel(UserHiveRepository()),
          ),
          ChangeNotifierProxyProvider<UserModel, ShiftListModel>(
              create: (_) =>
                  ShiftListModel(ShiftWebClient(), ShiftHiveRepository()),
              update: (_, uModel, slModel) {
                slModel!.update(uModel);
                uModel.update(slModel);
                return slModel;
              }),
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
            }));
  }
}
