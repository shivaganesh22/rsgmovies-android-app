import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
 
  
  bool showVideo=true;
  final TextEditingController _urlController = TextEditingController();
  List<dynamic> videoStreams = [];
  List<dynamic> audioStreams =[];
  Map<String,String> videoDetails ={};

  Future<void> _fetchStreams(String url) async {
    EasyLoading.show(status: "Fetching");
    http.Response res = await http.get(Uri.parse(
        "https://rsg-movies.vercel.app/api/youtube/?link=${url}"));
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      EasyLoading.showSuccess("Fetched");
      setState(() {
        videoDetails["title"]=json["title"];
        videoDetails["thumb"]=json["thumb"];
        videoStreams=json["videos"];
        audioStreams=json["audio"];
      });
    } else {
      EasyLoading.showError("Failed");
    }
  }

  Future<void> downloadVideo(stream) async {
    
    context.push(context
            .namedLocation("player", pathParameters: {"data":jsonEncode({"name":videoDetails['title'],"url":stream['url'] })}));
  }

  @override
  void initState() {
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
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(labelText: 'Enter YouTube URL'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _fetchStreams(_urlController.text),
                  child: Text('Fetch Streams'),
                ),
                SizedBox(height: 16.0),
                Text(videoDetails["title"]??'',
                style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.0),
                if(videoDetails.isNotEmpty)
                Image.network(videoDetails['thumb']!,width: 200,height: 150,),
                SizedBox(height: 16.0),
                Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  
                  onPressed: () {
                    setState(() {
                      showVideo = true;
                    });
                  },
                  child: Text('Video'),
                  style: showVideo==true?ElevatedButton.styleFrom(
                  primary: Colors.blue, // Set the background color here
                  onPrimary: Colors.white, // Set the text color
                ):ElevatedButton.styleFrom(
                  primary: Colors.white, // Set the background color here
                  onPrimary: Colors.black, // Set the text color
                ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showVideo = false;
                    });
                  },
                 style: showVideo==false?ElevatedButton.styleFrom(
                  primary: Colors.blue, // Set the background color here
                  onPrimary: Colors.white, // Set the text color
                ):ElevatedButton.styleFrom(
                  primary: Colors.white, // Set the background color here
                  onPrimary: Colors.black, // Set the text color
                ), 
                  child: Text('Audio'),
                ),
              ],
            ),
            SizedBox(height: 16),
            showVideo==true?
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
                  itemCount: videoStreams.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        downloadVideo(videoStreams[index]); 
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: videoStreams[index]["audio"]?Color(0xFF198754):Color.fromARGB(255, 25, 187, 219),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top:8),
                              child: Text(
                                videoStreams[index]["resolution"]
                                    
                                    .toString()
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: videoStreams[index]["audio"]==true?Colors.white:Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 1),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    videoStreams[index]["audio"]==true?
                                    Icon(
                                      Icons.videocam,
                                      color: Colors.white,
                                    ):Icon(
                                      Icons.music_off,
                                      color:Colors.white,
                                    ), // Replace with your desired icon
                                    SizedBox(
                                        width:
                                            8), // Add some space between the icon and text
                                    Text(
                                videoStreams[index]["codec"].toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: videoStreams[index]["audio"]==true?Colors.white:Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 1),
                              child: Text(
                                '${videoStreams[index]['size'].toStringAsFixed(2)} MB',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: videoStreams[index]["audio"]==true?Colors.white:Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ):GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 90,
                    childAspectRatio: 50.90,
                  ),
                  itemCount: audioStreams.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        downloadVideo(audioStreams[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFF198754),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top:8),
                              child: Text(
                                '${audioStreams[index]['resolution']}',
                                
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 1),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                          
                                    Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                    ), // Replace with your desired icon
                                    SizedBox(
                                        width:
                                            8), // Add some space between the icon and text
                                    Text(
                                audioStreams[index]['codec'].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 1),
                              child: Text(
                                '${audioStreams[index]['size'].toStringAsFixed(2)} MB',
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
                )
              ,],
            ),
          ),
        ),
      ),
    );
  }


}
