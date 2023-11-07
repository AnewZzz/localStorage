import 'dart:io';
import 'package:flutter/material.dart';
import 'package:new_test/downloaded_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:new_test/test_screen.dart';
import 'package:new_test/video_datas.dart';

class BasePage extends StatelessWidget {
  BasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<VideoData> listVideos = [
      const VideoData(
        name: 'You Video 1',
        path:
            'https://www.pexels.com/video/an-aerial-footage-of-surfers-on-the-sea-15271760/',
        type: VideoType.network,
      ),
      const VideoData(
        name: 'Network Video 2',
        path: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
        type: VideoType.network,
      ),
      const VideoData(
        name: 'HLS Streaming Video 1',
        path:
            'http://demo.unified-streaming.com/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        type: VideoType.network,
      ),
      const VideoData(
        name: 'File Video 1',
        path: 'System File Example',
        type: VideoType.file,
      ),
      const VideoData(
        name: 'Asset Video 1',
        path: 'assets/sample.mp4',
        type: VideoType.asset,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: listVideos.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  _downloadVideo(listVideos[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayers(
                        url: listVideos[index].path,
                        appbar: 'Player',
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(listVideos[index].name),
                  trailing: IconButton(
                    icon: Icon(Icons.download_for_offline_outlined),
                    onPressed: () async {
                      bool isDownloaded = await _downloadVideo(listVideos[index]);
                      if (isDownloaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Video Downloaded'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Video Already Downloaded'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DownloadedList()),
              );
            },
            child: Text('Downloaded Videos'),
          )
        ],
      ),
    );
  }

  Future<bool> _downloadVideo(VideoData videoData) async {
    final databasePath = await getDatabasesPath();
    final pathToDb = path.join(databasePath, 'video_database.db');
    final database = await openDatabase(pathToDb, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS Videos (id INTEGER PRIMARY KEY, name TEXT, path TEXT)',
      );
    });

    final List<Map<String, dynamic>> videos = await database.rawQuery('SELECT * FROM Videos WHERE name = ?', [videoData.name]);
    if (videos.isNotEmpty) {
      return false; // Video already downloaded
    }

    final response = await http.get(Uri.parse(videoData.path));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${videoData.name}.mp4');
    await file.writeAsBytes(response.bodyBytes);
    await _saveVideoToLocalDb(videoData.name, file.path, database);
    return true;
  }

  Future<void> _saveVideoToLocalDb(String name, String path, Database database) async {
    await database.transaction((txn) async {
      await txn.rawInsert('INSERT INTO Videos(name, path) VALUES(?, ?)', [name, path]);
    });
  }
}

