import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';
import 'package:RSG_MOVIES/main.dart';
import 'package:RSG_MOVIES/views/other/login.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';


class NotLoggedFileScreen extends StatefulWidget {
  const NotLoggedFileScreen({super.key});

  @override
  State<NotLoggedFileScreen> createState() => _NotLoggedFileScreenState();
}

class _NotLoggedFileScreenState extends State<NotLoggedFileScreen> {
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
        backgroundColor:Colors.indigoAccent,
        title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Image.asset(
                    "assets/logo.png",
                    width: 145,
                    fit: BoxFit.fill,
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
        child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("To access files you need to login"),
                      ElevatedButton(
                        onPressed: () async {
                          // Navigate to the login screen and wait for a result
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
        
                          // Check if login was successful
                          if (result == true) {
                            // If login was successful, refresh the UI
                            
                          }
                        },
                        child: Text("Login"),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}