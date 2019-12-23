import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData _appTheme;

Color paneBackgroundColor = Colors.grey.shade900;

ThemeData getAppTheme(BuildContext context) {
  if (_appTheme == null) _appTheme = _buildAppTheme(context);
  return _appTheme;
}

ThemeData _buildAppTheme(BuildContext context) {
  TextTheme textTheme = Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      );

  textTheme = textTheme.copyWith(
    display1: textTheme.display1.copyWith(
      fontWeight: FontWeight.bold,
    ),
    display2: textTheme.display2.copyWith(
      fontWeight: FontWeight.bold,
    ),
    display3: textTheme.display3.copyWith(
      fontWeight: FontWeight.bold,
    ),
    display4: textTheme.display4.copyWith(
      fontWeight: FontWeight.bold,
    ),
    headline: textTheme.headline.copyWith(
      fontWeight: FontWeight.bold,
    ),
    title: textTheme.title.copyWith(
      fontWeight: FontWeight.bold,
    ),
    subhead: textTheme.subhead.copyWith(),
    body2: textTheme.body2.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    body1: textTheme.body1.copyWith(
      fontSize: 14,
    ),
    caption: textTheme.caption.copyWith(
      color: Colors.white.withOpacity(0.6),
      fontSize: 12,
    ),
    button: textTheme.button.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
  );

  ButtonThemeData buttonTheme = Theme.of(context).buttonTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      );

  AppBarTheme appBarTheme = Theme.of(context).appBarTheme.copyWith(
        brightness: Brightness.dark,
        color: Colors.black.withOpacity(0.25),
        elevation: 0,
        iconTheme: IconThemeData(
          opacity: 1,
          color: Colors.white,
        ),
      );

  return ThemeData(
    brightness: Brightness.dark,
    appBarTheme: appBarTheme,
    primaryColor: Color(0xFF29b6f6),
    fontFamily: 'Montserrat',
    buttonTheme: buttonTheme,
    textTheme: GoogleFonts.montserratTextTheme(textTheme),
  );
}
