
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:RSG_MOVIES/main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class IBommaMovie extends StatefulWidget {
  final String link;

  const IBommaMovie({Key? key, required this.link}) : super(key: key);

  @override
  State<IBommaMovie> createState() => _IBommaMovieState();
}

class _IBommaMovieState extends State<IBommaMovie> {
  
  Map<String, dynamic> details = {};
  bool isLoading = true;

  Future apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://rsg-movies.vercel.app/api/ibomma/movie/?link=${widget.link}"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        
        details = json;
        isLoading = false;
      });
    } else {
      
      isLoading = false;
    }
  }

  Future<void> addTorrent(String id) async {
    EasyLoading.show(status: "Uploading");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/addtorrent/?link=${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );

      if (jsonDecode(res.body)["result"]==true) {
        EasyLoading.showSuccess("Uploaded");
        // showSnackBar(context, "Added Torrent", true);
        context.goNamed("Files");
      } else
        EasyLoading.dismiss();
        showSnackBar(context, jsonDecode(res.body)["result"], false);
    } else {
      EasyLoading.dismiss();
      showSnackBar(context, "Please Login to Upload", false);
    }
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
        title: Text("Movie Details"),
      ),
      body: isLoading
          ? _buildShimmerLoading()
          : details["name"] != null
              ? SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(top: 15, left: 24, right: 24),
                    child: Column(
                      children: [
                        Text(
                          details['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            child: Image.network(
                              details["image"] ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text('Genre :${details['genre']??""}'),
                        Text(details['cast']??''),
                        Text(details['director']??''),
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(details["desc"] ?? ''),
                        ),
                        HtmlWidget(
                          """<iframe width="300" height="200" src="${details['link']}"  frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>"""
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            ElevatedButton(child: Text('Trailer'),onPressed: () => {launch(details['trailer']??'')},),
                            SizedBox(width: 16),
                            ElevatedButton(child: Text('Download'),onPressed:() => {launch(details['dlink']??'')},),
                          ],)
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 15, left: 24, right: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 100,
                color: Colors.grey, // Adjust the shimmer color
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Container(
                  width: 200,
                  height: 250,
                  color: Colors.grey, // Adjust the shimmer color
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.white, // Adjust the shimmer color
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white, // Adjust the shimmer color
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey, // Adjust the shimmer color
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
