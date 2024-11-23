import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController _searchController = TextEditingController();
  List items = [], ends = [], pages = [];
  String name = "";
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

  Future<void> apicall(String url) async {
    http.Response res =
        await http.get(Uri.parse("https://rsg-movies.vercel.app/api$url"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        items = json['links'];
        ends = json['ends'];
        name = json['name'];
        pages = json['pages'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            _performSearch(value, "1");
          },
          onSubmitted: (value) {
            // Handle search on Enter key press
            _performSearch(value, "1");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
              _performSearch(_searchController.text, "1");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500)),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => {addTorrent(items[index]['link'])},
                child: ListTile(
                  title: Text(items[index]["name"] ?? '',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    "Created: ${items[index]['date']} | Size: ${items[index]['size']}",
                    textAlign: TextAlign.center,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: items[index]['link']));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Copied to clipboard'),
                          ));
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.upload,
                          color: Color(0xFF198754),
                        ),
                        onPressed: () {
                          addTorrent(items[index]['link']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (ends.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          apicall(ends[0]);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Icon(Icons.arrow_back_ios_new),
                      ),
                    // Add spacing between previous button and pages

                    Row(
                      children: List.generate(
                        pages.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: TextButton(
                            onPressed: () {
                              apicall(pages[index]['link']);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Text(pages[index]['name']),
                          ),
                        ),
                      ),
                    ),
                    if (ends.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          apicall(ends[1]);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: Icon(Icons.arrow_forward_ios),
                      ),
                  ],
                ),

              ),
            
            ],
          )
          
        ],
      )),
    );
  }

  Future<void> _performSearch(String query, String no) async {
    http.Response res = await http.get(Uri.parse(
        "https://rsg-movies.vercel.app/api/search/?q=${query}&page=${no}"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      setState(() {
        items = json['links'];
        ends = json['ends'];
        name = json['name'];
        pages = json['pages'];
      });
    }
  }
}
