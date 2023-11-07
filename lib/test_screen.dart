import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';


class VideoPlayers extends StatefulWidget {
  final String url;
  final String appbar;
  bool minimizedvideo;

  VideoPlayers({
    Key? key,
    required this.url,
    required this.appbar,
    this.minimizedvideo = false,
  }) : super(key: key);

  @override
  _VideoPlayersState createState() => _VideoPlayersState();
}

class _VideoPlayersState extends State<VideoPlayers> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController?.dispose();
  }

  void _initializePlayer() async {
    final videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // var userProv = context.watch<UserProvider>();

    return Container(
      // decoration: gradientTheam(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(widget.appbar),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);

                // userProv.toggleMiniPlayervideo();
                //  userProv.minimized ? userProv.toggleMiniPlayer() : null;

                // context
                //     .watch<UserProvider>()
                //     .setVideoUrl(widget.url, widget.appbar);
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: _chewieController != null &&
                          _chewieController!
                              .videoPlayerController.value.isInitialized
                      ? Chewie(
                          controller: _chewieController!,
                        )
                      : Stack(
                          children: [
                            // Center(child: Image.asset('asset/icon/logo1.png')),
                            const Center(child: CircularProgressIndicator())
                          ],
                        )),
              const Column(
                children: [],
              )
            ],
          ),
        ),
      ),
    );
  }
}