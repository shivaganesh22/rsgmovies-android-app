

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class TamilmvMovie extends StatefulWidget {
  final String link;

  const TamilmvMovie({Key? key, required this.link}) : super(key: key);

  @override
  State<TamilmvMovie> createState() => _TamilmvMovieState();
}

class _TamilmvMovieState extends State<TamilmvMovie> {
  List images = [], links = [];
  bool isDataLoaded = false;

  Future apicall() async {
    http.Response res = await http
        .get(Uri.parse("https://rsg-movies.vercel.app/api${widget.link}"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        links = json["links"];
        images = json["images"];
        isDataLoaded = true;
      });
    } else {}
  }

  Future<void> addTorrent(String id) async {
    EasyLoading.show(status: "Uploading");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/addtorrent/?link=${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );

      if (jsonDecode(res.body)["result"] == true) {
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
      body: SingleChildScrollView(
        child: isDataLoaded
            ? Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => {addTorrent(links[index]['link'])},
                        child: ListTile(
                          title: Text(links[index]["name"] ?? '',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.upload,
                              color: Color(0xFF198754),
                            ),
                            onPressed: () {
                              addTorrent(links[index]['link']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Image.network(
                          images[index]["link"] ?? '',
                          alignment: Alignment.center,
                        ),
                      );
                    },
                  ),
                ],
              )
            : Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ShimmerItem(),
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
        children: [
          ...List.generate(
            5,
            (index) => ListTile(
              title: Container(
                width: double.infinity,
                height: 20.0,
                color: Colors.white,
              ),
              trailing: Icon(Icons.upload),
            ),
          ),
          SizedBox(height: 10.0), // Adjust spacing as needed
          Container(
            width: 200,
            height: 250.0, // Set the desired height for the image container
            color: Colors.white,
          ),
          SizedBox(height: 10.0), // Adjust spacing as needed
        ],
      ),
    );
  }
}
