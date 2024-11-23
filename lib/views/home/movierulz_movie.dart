
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:RSG_MOVIES/main.dart';
import 'package:shimmer/shimmer.dart';

class MovierulzMovie extends StatefulWidget {
  final String link;

  const MovierulzMovie({Key? key, required this.link}) : super(key: key);

  @override
  State<MovierulzMovie> createState() => _MovierulzMovieState();
}

class _MovierulzMovieState extends State<MovierulzMovie> {
  List links = [];
  Map<String, dynamic> details = {};
  bool isLoading = true;

  Future apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://rsg-movies.vercel.app/api/movierulz/movie/?link=${widget.link}"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        links = json["links"];
        details = json["details"];
        isLoading = false;
      });
    } else {
      links = ["error"];
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
                        HtmlWidget(details["inf"] ?? ''),
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: HtmlWidget(details["desc"] ?? ''),
                        ),
                        //links
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 90,
                            childAspectRatio: 50.90,
                          ),
                          itemCount: links.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                addTorrent(links[index]["link"]);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color(0xFF198754),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Icon(
                                        Icons.upload,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 9, right: 9, bottom: 9),
                                      child: Text(
                                        links[index]["name"].toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 90,
                  childAspectRatio: 50.90,
                ),
                itemCount: 6, // Adjust the number of shimmer items as needed
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Container(
                            width: 24,
                            height: 24,
                            color: Colors.white, // Adjust the shimmer color
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 9, right: 9, bottom: 9),
                          child: Container(
                            width: double.infinity,
                            height: 20,
                            color: Colors.white, // Adjust the shimmer color
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
