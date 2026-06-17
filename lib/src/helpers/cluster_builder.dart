import 'package:flutter/material.dart';

class MarkerClusterBuilder {
  static Widget buildClusterMarker({
    required int count,
    double size = 50,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
    TextStyle? textStyle,
    Widget? icon,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: icon ??
            Text(
              count.toString(),
              style: textStyle ??
                  TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
            ),
      ),
    );
  }

  static Widget buildCustomCluster({
    required int count,
    required Widget Function(int count) builder,
  }) {
    return builder(count);
  }
}
