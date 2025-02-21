import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaItemWidget extends StatefulWidget {
  final String url;

  const MediaItemWidget({super.key, required this.url});

  @override
  State<MediaItemWidget> createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> {
  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isVideo = _checkIfVideo(widget.url);
    if (_isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
          _controller!.setLooping(true);
          _controller!.addListener(() {
            if (!_controller!.value.isPlaying &&
                _controller!.value.position == _controller!.value.duration) {
              setState(() => _isPlaying = false);
            }
          });
        });
    }
  }

  bool _checkIfVideo(String url) {
    return url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.avi') ||
        url.endsWith('.MP4') ||
        url.endsWith('.MOV') ||
        url.endsWith('.AVI');
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller!.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 200, // Changed from 120
          height: 200, // Changed from 120
          child: Image.network(
            widget.url,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
          child: CircularProgressIndicator.adaptive(
        backgroundColor: Colors.white,
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 200, // Changed from 120
        height: 200, // Changed from 120
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            Positioned(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
