import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  Map<dynamic, dynamic> items = {};
  List folders = [], files = [], torrents = [];
  List<bool> isEditing = [], isEditingFile = [];
  late Timer continuousTimer;
  bool isDataLoaded = false;

  Future<void> apicall() async {
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/files/'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(res.body);
        final Map<dynamic, dynamic> result = json.cast<dynamic, dynamic>();
        setState(() {
          items = result;
          folders = result["folders"];
          files = result["files"];
          torrents = result["torrents"];
          isDataLoaded = true;
          isEditing = List.generate(folders.length, (index) => false);
          isEditingFile = List.generate(files.length, (index) => false);
          // Set isDataLoaded to true after data is loaded
        });
      } else {
        // Handle the error case if needed
      }
    }
  }

  @override
  void dispose() {
    continuousTimer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  Future<void> deleteTorrent(id) async {
    EasyLoading.show(status: "Deleting Torrent");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/deletetorrent/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      apicall();
      // showSnackBar(context, "Deleted Torrent", true);
      EasyLoading.showSuccess("Deleted");
    }
  }

  Future<void> deleteFolder(id) async {
    EasyLoading.show(status: "Deleting Folder");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/deletefolder/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      apicall();
      EasyLoading.showSuccess("Deleted");
      // showSnackBar(context, "Deleted Folder", true);
    }
  }

  Future<void> deleteFile(id) async {
    EasyLoading.show(status: "Deleting File");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/deletefile/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      apicall();
      EasyLoading.showSuccess("Deleted");
      // showSnackBar(context, "Deleted File", true);
    }
  }

  Future<void> downloadFolder(id) async {
    EasyLoading.show(status: "Starting");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/folder/file/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );

      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        launch(jsonDecode(res.body)['url']);
      } else {
        EasyLoading.dismiss();
        showSnackBar(context, "No file to download", false);
      }
    }
  }

  Future<void> downloadFile(id) async {
    EasyLoading.show(status: "Starting");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/file/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        launch(jsonDecode(res.body)['url']);
      } else {
        EasyLoading.dismiss();
        showSnackBar(context, "No file to download", false);
      }
    }
  }

  Future<void> editFolder(name, id) async {
    EasyLoading.show(status: "Editing");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse(
            'https://rsg-movies.vercel.app/api/rename/folder/${id}/?name=${name}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      apicall();
      startContinuousTimer();
      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Edited");
      } else {
        final json = jsonDecode(res.body);
        EasyLoading.showError(json['error']);
      }
    }
  }

  Future<void> editFile(name, id) async {
    EasyLoading.show(status: "Editing");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse(
            'https://rsg-movies.vercel.app/api/rename/file/${id}/?name=${name}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      apicall();
      startContinuousTimer();
      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Edited");
      } else {
        final json = jsonDecode(res.body);
        EasyLoading.showError(json['error']);
      }
    }
  }

  Future<void> playFolder(id) async {
    EasyLoading.show(status: "Playing");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/folder/file/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        // context.goNamed("player",pathParameters: {"data":res.body});
        context.push(context
            .namedLocation("player", pathParameters: {"data": res.body}));
      } else {
        EasyLoading.dismiss();
        showSnackBar(context, "No file to play", false);
      }
    }
  }

  Future<void> playFile(id) async {
    EasyLoading.show(status: "Playing");
    if (await AuthService.isLogged()) {
      Map<String, String> user = await AuthService.getLoginDetails();
      http.Response res = await http.post(
        Uri.parse('https://rsg-movies.vercel.app/api/file/${id}'),
        body: {"email": user["email"]!, "password": user["password"]!},
      );
      if (res.statusCode == 200) {
        EasyLoading.dismiss();
        context.push(context
            .namedLocation("player", pathParameters: {"data": res.body}));
      } else {
        EasyLoading.dismiss();
        showSnackBar(context, "No file to play", false);
      }
    }
  }

  void startContinuousTimer() {
    continuousTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await apicall();
    });
  }

  @override
  void initState() {
    super.initState();
    apicall();
    startContinuousTimer();
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
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
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
        actions: [
          if (items.isNotEmpty)
            Text(
                '${(items['space_used'] / (1024 * 1024 * 1024)).toStringAsFixed(1)} | ${(items['space_max'] / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB'),
          IconButton(
              onPressed: () {
                context.push(context.namedLocation('Addtorrent'));
              },
              icon: Icon(Icons.add)),
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
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Shimmer effect for torrents
                    if (!isDataLoaded)
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ShimmerItem(),
                      ),
                    if (isDataLoaded)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: torrents.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  torrents[index]["name"],
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: Text(
                                  torrents[index]['warnings'] == '[]'
                                      ? ''
                                      : torrents[index]['warnings'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${torrents[index]['progress']} % "),
                                  Text(
                                      "${(torrents[index]['size'] / 1073741824).toStringAsFixed(2)} GB "),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      deleteTorrent(torrents[index]['id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                    // Shimmer effect for folders
                    if (!isDataLoaded)
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ShimmerItem(),
                      ),
                    if (isDataLoaded)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Map<String, String> params = {
                                "id": folders[index]['id'].toString()
                              };
                              context.goNamed("openfolder",
                                  pathParameters: params);
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  title: isEditing[index]
                                      ? TextField(
                                          controller: TextEditingController(
                                              text: folders[index]['name']),
                                          onSubmitted: (text) {
                                            editFolder(
                                                text, folders[index]['id']);
                                          },
                                        )
                                      : Text(
                                          folders[index]["name"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_circle_filled,
                                        color: Color(0xFF198754),
                                      ),
                                      onPressed: () {
                                        playFolder(folders[index]['id']);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.download,
                                        color: Colors.teal,
                                      ),
                                      onPressed: () {
                                        downloadFolder(folders[index]['id']);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.folder_open,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () {
                                        Map<String, String> params = {
                                          "id": folders[index]['id'].toString()
                                        };
                                        context.goNamed("openfolder",
                                            pathParameters: params);
                                      },
                                    ),
                                    IconButton(
                                      icon: isEditing[index]
                                          ? Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            )
                                          : Icon(
                                              Icons.edit,
                                              color: Colors.deepPurple,
                                            ),
                                      onPressed: () {
                                        setState(() {
                                          isEditing[index] = !isEditing[index];
                                          isEditing[index]
                                              ? continuousTimer.cancel()
                                              : startContinuousTimer();
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteFolder(folders[index]["id"]);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    // Shimmer effect for files
                    if (!isDataLoaded)
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ShimmerItem(),
                      ),
                    if (isDataLoaded)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: isEditingFile[index]
                                    ? TextField(
                                        controller: TextEditingController(
                                            text: files[index]['name']),
                                        onSubmitted: (text) {
                                          editFile(text,
                                              files[index]['folder_file_id']);
                                        },
                                      )
                                    : Text(
                                        files[index]["name"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.play_circle_filled,
                                      color: Color(0xFF198754),
                                    ),
                                    onPressed: () {
                                      playFile(files[index]['folder_file_id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.download,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () {
                                      downloadFile(
                                          files[index]['folder_file_id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: isEditingFile[index]
                                        ? Icon(
                                            Icons.close,
                                            color: Colors.black,
                                          )
                                        : Icon(
                                            Icons.edit,
                                            color: Colors.deepPurple,
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        isEditingFile[index] =
                                            !isEditingFile[index];
                                        isEditingFile[index]
                                            ? continuousTimer.cancel()
                                            : startContinuousTimer();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      deleteFile(
                                          files[index]['folder_file_id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50.0,
              height: 20.0,
              color: Colors.white,
            ),
            Container(
              width: 100.0,
              height: 20.0,
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
