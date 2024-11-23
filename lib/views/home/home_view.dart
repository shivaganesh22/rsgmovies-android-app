import 'dart:convert';

import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List items = [];
  bool isLoading = true, isNew = false;

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

  Future apicall() async {
    http.Response res =
        await http.get(Uri.parse("https://rsg-movies.vercel.app/api/movierulz"));
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

  @override
  Widget build(BuildContext context) {
    final appcastURL = 'https://auitb.000webhostapp.com/appcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: UpgradeAlert(
        upgrader: Upgrader(
          canDismissDialog: false,
          appcastConfig: cfg,
          debugLogging: true,
        ),
        child: Scaffold(
          appBar: EasySearchBar(
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 145,
                    fit:BoxFit.cover
                  ),
                ),
                
              ],
            ),
            putActionsOnRight: true,
            onSearch: (value) async {
              http.Response res = await http.get(Uri.parse(
                  "https://rsg-movies.vercel.app/api/movierulz/search/$value"));
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
            },
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
                        showSnackBar(
                            context, "You are already logged in", true);
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
          body: RefreshIndicator(
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent:
                                  300, // Adjusted to account for padding
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  context.goNamed("moviedetails",
                                      pathParameters: {
                                        "link": items[index]['link']
                                      });
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
                                          maxLines: 3,
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
          mainAxisExtent: 300,
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

// import 'package:flutter/material.dart';
// import 'package:upgrader/upgrader.dart';


// class HomeView extends StatelessWidget {
//   HomeView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final appcastURL =
//         'https://auitb.000webhostapp.com/appcast.xml';
//     final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);

//     return MaterialApp(
//       title: 'Upgrader Example',
//       home: Scaffold(
//           appBar: AppBar(title: Text('Upgrader Appcast Example')),
//           body: UpgradeAlert(
//             upgrader: Upgrader(
//               appcastConfig: cfg,
//               debugLogging: true,
//               durationUntilAlertAgain: Duration(seconds: 2)
//             ),
//             child: Center(child: Text('Checking...')),
//           )),
//     );
//   }
// }
