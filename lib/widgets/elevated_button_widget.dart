import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ElevateButtonWidget extends StatefulWidget {
  final String labelText, logoText;
  final Color borderColor, foregroundColor, backgroundColor;
  final Color? textColor;
  final double textSize, borderRadius, padding;
  final bool icon;
  final FontWeight fontWeight;
  final VoidCallback? onPressed;

  const ElevateButtonWidget({
    Key? key,
    required this.borderColor,
    this.onPressed,
    this.logoText = "f",
    required this.backgroundColor,
    this.icon = false,
    required this.fontWeight,
    required this.borderRadius,
    required this.padding,
    required this.foregroundColor,
    required this.textSize,
    this.textColor,
    required this.labelText,
  }) : super(key: key);

  @override
  State<ElevateButtonWidget> createState() => _TextButtonWidgetState();
}

class _TextButtonWidgetState extends State<ElevateButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: widget.icon
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SvgPicture.asset('assets/upload_icon.svg', height: 12),
                // SizedBox(width: widget.logoText == "f" ? 25 : 20),
                Padding(
                  padding: widget.logoText == "f"
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(right: 25),
                  child: Text(
                    widget.labelText,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.textSize,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              widget.labelText,
              style: TextStyle(
                  fontSize: widget.textSize,
                  fontWeight: widget.fontWeight,
                  color: Colors.black),
            ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.all(widget.padding)),
        foregroundColor:
            MaterialStateProperty.all<Color>(widget.foregroundColor),
        backgroundColor:
            MaterialStateProperty.all<Color>(widget.backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius,
            ),
          ),
        ),
      ),
      onPressed: widget.onPressed,
    );
  }
}
