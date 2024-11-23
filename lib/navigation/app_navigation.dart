import 'dart:convert';

import 'package:RSG_MOVIES/views/ibomma/ibomma.dart';
import 'package:RSG_MOVIES/views/ibomma/ibommamovie.dart';
import 'package:RSG_MOVIES/views/other/sports_view.dart';

import 'package:flutter/material.dart';
import 'package:RSG_MOVIES/auth.dart';

import 'package:RSG_MOVIES/views/files/files_screen.dart';
import 'package:RSG_MOVIES/views/files/not_logged_files.dart';
import 'package:RSG_MOVIES/views/files/open_folder_screen.dart';
import 'package:RSG_MOVIES/views/files/player.dart';
import 'package:RSG_MOVIES/views/home/movierulz_movie.dart';
import 'package:RSG_MOVIES/views/other/add_torrent_screen.dart';
import 'package:RSG_MOVIES/views/other/login.dart';

import 'package:RSG_MOVIES/views/tamilmv/tamilmv.dart';
import 'package:RSG_MOVIES/views/tamilmv/tamilmv_movie.dart';
import 'package:RSG_MOVIES/views/youtube/youtube_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:RSG_MOVIES/views/home/home_view.dart';
import 'package:RSG_MOVIES/views/search/search_view.dart';

import 'package:RSG_MOVIES/views/wrapper/main_wrapper.dart';

class AppNavigation {
  AppNavigation._();

  static String initial = "/home";

  // Private navigators
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorFiles =
      GlobalKey<NavigatorState>(debugLabel: 'shellFiles');
  static final _shellNavigatorIBomma =
      GlobalKey<NavigatorState>(debugLabel: 'shellIBomma');
  static final _shellNavigatorYoutube =
      GlobalKey<NavigatorState>(debugLabel: 'shellYoutube');

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: initial,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      /// MainWrapper
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: <StatefulShellBranch>[
          /// Brach Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: <RouteBase>[
              GoRoute(
                path: "/home",
                name: "Home",
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeView(),
                routes: [
                  GoRoute(
                    path: 'moviedetails/:link',
                    name: 'moviedetails',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage<void>(
                        key: state.pageKey,
                        child: MovierulzMovie(
                            link: state.pathParameters["link"] ?? ''),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          /// Brach Setting
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFiles,
            routes: <RouteBase>[
              GoRoute(
                path: "/files",
                name: "Files",
                // builder: (BuildContext context, GoRouterState state) =>
                //     const FilesScreen(),
                builder: (BuildContext context, GoRouterState state) {
                  return FutureBuilder<bool>(
                    future: AuthService.isLogged(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == true) {
                          // User is logged in, navigate to FilesScreen
                          return const FilesScreen();
                        } else {
                          // User is not logged in, navigate to NotLoggedScreen
                          return const NotLoggedFileScreen();
                        }
                      } else {
                        // While waiting for the result, show a loading indicator or any other widget
                        return CircularProgressIndicator(); // You can replace this with your loading widget
                      }
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'openfolder/:id',
                    name: 'openfolder',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage<void>(
                        key: state.pageKey,
                        child:
                            OpenFolder(id: state.pathParameters["id"] as String),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
           
                ],
              ),
            ],
          ),

         

          StatefulShellBranch(
            navigatorKey: _shellNavigatorIBomma,
            routes: <RouteBase>[
              GoRoute(
                path: "/ibomma",
                name: "ibomma",
                builder: (BuildContext context, GoRouterState state) =>
                    const IBommaView(),
                
              ),
            ],
          ),


          StatefulShellBranch(
            navigatorKey: _shellNavigatorYoutube,
            routes: <RouteBase>[
              GoRoute(
                path: "/youtube",
                name: "Youtube",
                builder: (BuildContext context, GoRouterState state) =>
                    const YoutubeScreen(),
              
              ),
            ],
          ),
        ],
      ),

      /// Search
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/search',
        name: "Search",
        builder: (context, state) => SearchView(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        name: "Login",
        builder: (context, state) => LoginScreen(
          key: state.pageKey,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/player/:data',
        name: "player",
        builder: (context, state) => PlayerScreen(
          key: state.pageKey,data:jsonDecode(state.pathParameters["data"]!)
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/addtorrent',
        name: "Addtorrent",
        builder: (context, state) => AddTorrentScreen(
          key: state.pageKey
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ibommamovie/:link',
        name: "ibommamovie",
        builder: (context, state) => IBommaMovie(
          key: state.pageKey,link: state.pathParameters['link']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/sports',
        name: "sports",
        builder: (context, state) => SportsView(
          key: state.pageKey
        ),
      ),
      
      
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tamilmv',
        name: "tamilmv",
        builder: (context, state) => TamilmvScreen(
          key: state.pageKey
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tamilmvmovie/:link',
        name: "tamilmvmovie",
        builder: (context, state) => TamilmvMovie(
          key: state.pageKey,link: state.pathParameters['link']!,
        ),
      ),
      
    
      
    ],
  );
}



