// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontFamily {
  static const String INTER = 'Inter';
}

class AppFontWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

//typography
const INTER_16 = 'INTER_16';
const INTER_17 = 'INTER_17';
const INTER_13 = 'INTER_13';
const INTER_12 = 'INTER_12';

TextStyle textStyle = const TextStyle(fontFamily: FontFamily.INTER);

Map<String, TextStyle> basicTextStylesMap = {
  INTER_12: textStyle.copyWith(fontSize: ScreenUtil().setSp(12), fontWeight: AppFontWeight.regular),
  INTER_13: textStyle.copyWith(fontSize: ScreenUtil().setSp(13), fontWeight: AppFontWeight.regular),
  INTER_16: textStyle.copyWith(fontSize: ScreenUtil().setSp(16), fontWeight: AppFontWeight.regular),
  INTER_17: textStyle.copyWith(fontSize: ScreenUtil().setSp(17), fontWeight: AppFontWeight.bold),
};

TextStyle getTextStyle(String textStyleKey,
    {Color? color,
    height,
    letterSpacing,
    double? wordSpacing,
    TextDecoration? textDecoration,
    FontWeight? fontWeight,
    FontStyle? fontStyle}) {
  TextStyle selectedTextStyle = basicTextStylesMap[textStyleKey]!;
  if (color != null) {
    selectedTextStyle = selectedTextStyle.copyWith(color: color);
  }
  if (height != null) {
    selectedTextStyle = selectedTextStyle.copyWith(height: height);
  }
  if (letterSpacing != null) {
    selectedTextStyle = selectedTextStyle.copyWith(letterSpacing: letterSpacing);
  }
  if (wordSpacing != null) {
    selectedTextStyle = selectedTextStyle.copyWith(wordSpacing: wordSpacing);
  }
  if (textDecoration != null) {
    selectedTextStyle = selectedTextStyle.copyWith(decoration: textDecoration);
  }
  if (fontWeight != null) {
    selectedTextStyle = selectedTextStyle.copyWith(fontWeight: fontWeight);
  }
  if (fontStyle != null) {
    selectedTextStyle = selectedTextStyle.copyWith(fontStyle: fontStyle);
  }

  return selectedTextStyle;
}
