import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SportsView extends StatefulWidget {
  const SportsView({super.key});

  @override
  State<SportsView> createState() => _SportsViewState();
}

class _SportsViewState extends State<SportsView> {
  String items = "";
  WebViewController controller = WebViewController()
..loadRequest(Uri.parse("https://rsg-movies.vercel.app/api/sports"))
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("TV Channels"),
        ),
        body: WebViewWidget(
          controller: controller,
        ));
  }
}
