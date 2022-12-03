import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:webview_flutter/webview_flutter.dart';

class ShowWebPage extends StatefulWidget {
  final String url;
  final String title;
  const ShowWebPage({Key? key, required this.url, required this.title})
      : super(key: key);

  @override
  State<ShowWebPage> createState() => _ShowWebPageState();
}

class _ShowWebPageState extends State<ShowWebPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4d047d),
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back)),
        title: Text(widget.title),
      ),
      body: WebView(
        // initialUrl: 'https://flutter.dev',
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          print('>> webview - onPageFinished : url = $url');
        },
      ),
    );
  }
}
