import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddTorrentScreen extends StatefulWidget {
  const AddTorrentScreen({super.key});

  @override
  State<AddTorrentScreen> createState() => _AddTorrentScreenState();
}

class _AddTorrentScreenState extends State<AddTorrentScreen> {
  TextEditingController _searchController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Paste Magnet Url...",
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            
          },
          onSubmitted: (value) {
            // Handle search on Enter key press
            addTorrent(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              
              addTorrent(_searchController.text);
            },
          ),
        ],
      ),
      
    );
  }

  Future<void> _performSearch(String query, String no) async {
    http.Response res = await http.get(Uri.parse(
        "https://rsg-movies.vercel.app/api/search/?q=${query}&page=${no}"));
    if (res.statusCode == 200) {
      
    }
  }
}