
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: Colors.white,
      backgroundColor: Colors.white.withOpacity(0.2),
      strokeWidth: 2,
    );
  }
}
