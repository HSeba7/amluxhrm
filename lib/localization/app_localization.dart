import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'en_us/en_us_translations.dart';
import 'en_us/pl_PL_translation.dart';

class AppLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'pl_PL': plPL,
      };
}
