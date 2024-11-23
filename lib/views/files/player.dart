import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

class PlayerScreen extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const PlayerScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double progress = 0.0;
  // late VideoPlayerController videoPlayerController;
  late CachedVideoPlayerController _videoPlayerController;
  // late CustomVideoPlayerWebController _customVideoPlayerWebController;

  late CustomVideoPlayerController _customVideoPlayerController;
  final CustomVideoPlayerSettings _customVideoPlayerSettings =
      const CustomVideoPlayerSettings(showSeekButtons: true);
  String videoUrl = "";

  bool isPermission = false;
  var checkAllPermissions = CheckPermission();
  bool downloading = false;
  bool fileExists = false;
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();
  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/${widget.data['name']}.mkv';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      downloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    checkFileExit();
    videoUrl = widget.data['url'];
    
    _videoPlayerController = CachedVideoPlayerController.network(videoUrl)
      ..initialize().then((value) {
        setState(() {});
        // Prevent the screen from turning off while the video is playing
        Wakelock.enable();
      });

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: _videoPlayerController,
      customVideoPlayerSettings: _customVideoPlayerSettings,
    );
  }

  openfile() {
    OpenFile.open(filePath);
  }

  Future<void> downloadVideo() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/${widget.data['name']}.mkv';
    setState(() {
      downloading = true;
      progress = 0;
    });

    try {
      await Dio().download(widget.data['url'], filePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total) * 100;
        });
      }, cancelToken: cancelToken);
      setState(() {
        downloading = false;
        fileExists = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        downloading = false;
      });
    }
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    // Release the wakelock when the video is disposed
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24, left: 10, right: 10),
            child: Text(
              widget.data['name'],
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, left: 10, right: 10),
            child: CustomVideoPlayer(
                customVideoPlayerController: _customVideoPlayerController),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isPermission
                    ? fileExists
                        ? ElevatedButton(
                            onPressed: () async {
                              openfile();
                            },
                            child: Icon(Icons.folder_open),
                          )
                        : downloading
                            ? ElevatedButton(
                                onPressed: () async {
                                  cancelDownload();
                                },
                                child: Text(
                                    " ${progress.toStringAsFixed(2)} % cancel"),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  downloadVideo();
                                },
                                child: Icon(Icons.download),
                              )
                    : ElevatedButton(
                        onPressed: () async {
                          CheckPermission();
                          checkPermission();
                        },
                        child: Text("Permission Denied"),
                      ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Copy to clipboard
                    Clipboard.setData(ClipboardData(text: widget.data['url']));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Copied to clipboard'),
                    ));
                  },
                  child: Icon(Icons.copy),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Share content
                    Share.share(
                        'Download ${widget.data['name']} \n${widget.data['url']}');
                  },
                  child: Icon(Icons.share),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30, left: 10, right: 10),
            child: ElevatedButton(
              onPressed: () {
                launch(widget.data['url']);
              },
              child: Icon(Icons.open_in_browser),
            ),
          )
        ],
      ),
    );
  }
}

class DirectoryPath {
  getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }
}

class CheckPermission {
  isStoragePermission() async {
    var isStorage = await Permission.storage.status;
    if (!isStorage.isGranted) {
      await Permission.storage.request();
      if (!isStorage.isGranted) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}
