import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class IBommaView extends StatefulWidget {
  const IBommaView({super.key});

  @override
  State<IBommaView> createState() => _IBommaViewState();
}

class _IBommaViewState extends State<IBommaView> {
  List items = [];
  bool isLoading = true, isNew = false;

  Future apicall() async {
    http.Response res =
        await http.get(Uri.parse("https://rsg-movies.vercel.app/api/ibomma/"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final result = json["movies"] as List;
      setState(() {
        items = result;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    apicall();
    super.initState();
  }
  Future<bool> _onBackPressed() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit Confirmation'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar (
        title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 145,
                    fit: BoxFit.cover,
                  ),
                ),
                
              ],
            ),
        
        backgroundColor: Colors.indigoAccent,
        actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Home"), value: "Home"),
                  PopupMenuItem(child: Text("TV Channels"), value: "Sports"),
                  PopupMenuItem(child: Text("Tamilmv"), value: "Tamilmv"),
                  PopupMenuItem(child: Text("Login"), value: "Login"),
                  PopupMenuItem(child: Text("Signup"), value: "Signup"),
                  PopupMenuItem(child: Text("Logout"), value: "Logout"),
                ],
                onSelected: (String newValue) async {
                  // Update the selected index based on the selected menu item
                  switch (newValue) {
                    case "Home":
                      context.goNamed("Home");
                      break;
                    case "Sports":
                      context.push(context.namedLocation("sports"));
                    case "Tamilmv":
                      context.push(context.namedLocation("tamilmv"));
                      break;
      
                    case "Login":
                      if (await AuthService.isLogged()) {
                        showSnackBar(context, "You are already logged in", true);
                      } else {
                        context.push(context.namedLocation("Login"));
                      }
                      break;
                    case "Signup":
                      launch("https://Seedr.cc");
                      break;
                    case "Logout":
                      if (await AuthService.isLogged()) {
                        AuthService.clearLoginDetails();
                        showSnackBar(context, "Logout Successful", true);
                        context.replaceNamed("Home");
                      } else {
                        showSnackBar(context, "You are not logged in", false);
                      }
                    default:
                      context.goNamed("Home");
                  }
                },
              ),
            ],
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: RefreshIndicator(
          onRefresh: apicall,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: isLoading
                  ? _buildShimmerLoading()
                  : Column(
                      children: [
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent:
                                290, // Adjusted to account for padding
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                context.push(context
              .namedLocation("ibommamovie", pathParameters: {"link": items[index]['link']}));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        items[index]["image"],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        items[index]["name"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 290,
        ),
        itemCount: 6, // Adjust the number of shimmer items as needed
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 150,
                  color: Colors.grey, // Adjust the shimmer color
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    height: 20,
                    color: Colors.grey, // Adjust the shimmer color
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
