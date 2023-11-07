import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DownloadedList extends StatelessWidget {
  const DownloadedList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Videos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDownloadedVideosFromDb(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final videoId = snapshot.data![index]['id'];
                final videoName = snapshot.data![index]['name'];
                return ListTile(
                  title: Text(videoName),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteVideo(videoId);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteVideo(int videoId) async {
    final databasePath = await getDatabasesPath();
    final pathToDb = path.join(databasePath, 'video_database.db');
    final database = await openDatabase(
      pathToDb,
      version: 1,
    );

    await database.delete('Videos', where: 'id = ?', whereArgs: [videoId]);
  }

  Future<List<Map<String, dynamic>>> _getDownloadedVideosFromDb() async {
    final databasePath = await getDatabasesPath();
    final pathToDb = path.join(databasePath, 'video_database.db');
    final database = await openDatabase(
      pathToDb,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS Videos (id INTEGER PRIMARY KEY, name TEXT, path TEXT)',
        );
      },
    );

    final List<Map<String, dynamic>> videos = await database.rawQuery('SELECT * FROM Videos');
    return videos;
  }
}
