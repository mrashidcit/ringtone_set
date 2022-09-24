import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: const Color(0XFFD8D8D8).withAlpha(23),
        valueColor: const AlwaysStoppedAnimation(Color(0XFFFFFFFF)),
        strokeWidth: 1,
      ),
    );
  }
}

showMessage(BuildContext context,
    {@required String? message,
      Color textColor = Colors.white}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color(0xFF4d047d).withOpacity(0.8),
      content: Text(message!,style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 15)),
    ),
  );
}
