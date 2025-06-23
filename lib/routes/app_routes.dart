import 'package:get/get_navigation/src/routes/get_route.dart';
import '../presentation/splash_screen.dart';

class AppRoutes {
  static List<GetPage> routes() {
    return [
      GetPage(name: "/", page: () => const SplashScreen()),
    ];
  }
}
