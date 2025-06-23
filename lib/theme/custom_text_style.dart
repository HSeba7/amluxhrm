import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:work_reader/core/utils/size_utils.dart';
import 'package:work_reader/theme/theme_helper.dart';

class CustomTextStyles {
  static get buttonText => GoogleFonts.inter(
        color: appTheme.blue,
        textStyle: TextStyle(
          fontSize: 22.fSize,
          fontWeight: FontWeight.w600,
        ),
      );

  static get appBarText => GoogleFonts.inter(
        color: appTheme.appWhite,
        textStyle: TextStyle(
          fontSize: 30.fSize,
          fontWeight: FontWeight.w600,
        ),
      );

  static get poppinsText => GoogleFonts.poppins(
        color: appTheme.grey68,
        textStyle: TextStyle(
          fontSize: 15.fSize,
          fontWeight: FontWeight.w700,
        ),
      );
}

extension TextStyleExtensions on TextStyle {
  TextStyle get inter => copyWith(fontFamily: 'Inter');
}
