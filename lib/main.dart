import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_reader/routes/app_routes.dart';
import 'package:work_reader/theme/theme_helper.dart';
import 'core/utils/size_utils.dart';
import 'localization/app_localization.dart';

void main() {
  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Reader',
      translations: AppLocalization(),
      // locale: Get.deviceLocale,
      locale: const Locale('pl', 'PL'),
      fallbackLocale: const Locale('en', 'US'),
      theme: theme,
      initialRoute: '/',
      getPages: AppRoutes.routes(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
