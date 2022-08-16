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
