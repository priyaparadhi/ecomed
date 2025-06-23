import 'package:flutter/material.dart';

class Appstyles {
  static final primaryColor = Colors.blue.shade50;
  static const secondaryColor = Color.fromARGB(255, 187, 222, 251);
  static const tabcolor = Colors.white;
  static const containercolor = Colors.white;
  static const blue = Colors.blue;
  static const green = Colors.green;

  static InputDecoration inputtextfield({
    required String label,
    Icon? icon,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextStyle? labelStyle,
    double borderRadius =
        12.0, // Default border radius is 8.0, can be customized
    TextInputType keyboardType =
        TextInputType.text, // Default keyboard type is TextInputType.text
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      labelText: label, // Label text
      hintText: hint, // Optional hint text
      contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10), // Padding for smaller height and spacing
      fillColor: Colors.white,
      labelStyle: labelStyle ??
          TextStyle(
            fontSize: 14,
            overflow: TextOverflow.ellipsis,
          ), // Default label style
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadius), // Rounded corners with dynamic radius
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadius), // Rounded corners on the enabled state
        borderSide:
            BorderSide(color: Colors.grey), // Grey border for enabled state
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            borderRadius), // Rounded corners on the focused state
        borderSide:
            BorderSide(color: Colors.black), // Blue border for focused state
      ),
      suffixIcon:
          suffixIcon, // Optional suffix icon (like a clear button or calendar icon)
    );
  }

  static ButtonStyle blueButtonStyle({
    Color backgroundColor = secondaryColor, // Default background color as blue
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    WidgetStateProperty<TextStyle>? textStyle,
    WidgetStateProperty<EdgeInsetsGeometry>? padding,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: borderRadius,
      )),
      padding: padding ??
          WidgetStateProperty.all(
              EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
      textStyle: textStyle ??
          WidgetStateProperty.all(TextStyle(fontSize: 14, color: Colors.white)),
    );
  }

  static Card cardStyle({
    required Widget child,
    Color color = containercolor,
    double elevation = 2,
    BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(15)),
    Color borderColor = Colors.black45,
    double borderWidth = 1.0,
    EdgeInsetsGeometry margin = const EdgeInsets.all(7),
  }) {
    return Card(
      color: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      margin: margin,
      child: child,
    );
  }
}
