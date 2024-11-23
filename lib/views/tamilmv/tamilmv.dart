

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TamilmvScreen extends StatefulWidget {
  const TamilmvScreen({super.key});

  @override
  State<TamilmvScreen> createState() => _TamilmvScreenState();
}

class _TamilmvScreenState extends State<TamilmvScreen> {
  String items = "";
  bool isDataLoaded = false;

  Future apicall() async {
    http.Response res =
        await http.get(Uri.parse("https://rsg-movies.vercel.app/api/tamilmv"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        items = json["items"];
        isDataLoaded = true;
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    apicall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TamilMV"),
      ),
      body: RefreshIndicator(
        onRefresh: apicall,
        child: Padding(
          padding: EdgeInsets.only(left: 5),
          child: SingleChildScrollView(
            child: isDataLoaded
                ? HtmlWidget(
                    items,
                    onTapUrl: (url) async {
                      if (url.contains('doodplay')) {
                        String dlink = url.split('?link=')[1];
                        launch(dlink);
                      } else
                        context.push(context
            .namedLocation("tamilmvmovie", pathParameters: {"link": url }));
                      return Future.value(true);
                    },
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ShimmerItem(),
                  ),
          ),
        ),
      ),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => ListTile(
            title: Container(
              width: double.infinity,
              height: 20.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 15.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
