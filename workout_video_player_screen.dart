import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:fitflow/config/theme_config.dart';
import 'package:fitflow/models/workout_category.dart';

class WorkoutVideoPlayerScreen extends StatefulWidget {
  final WorkoutCategory workout;
  final String videoAsset;

  const WorkoutVideoPlayerScreen({
    super.key,
    required this.workout,
    required this.videoAsset,
  });

  @override
  State<WorkoutVideoPlayerScreen> createState() => _WorkoutVideoPlayerScreenState();
}

class _WorkoutVideoPlayerScreenState extends State<WorkoutVideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isFullScreen = false;
  double _currentPosition = 0;
  double _videoDuration = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    
    // Set preferred orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Set full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(widget.videoAsset);
      await _videoPlayerController.initialize();
      
      _videoDuration = _videoPlayerController.value.duration.inMilliseconds.toDouble();
      
      _videoPlayerController.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _videoPlayerController.value.position.inMilliseconds.toDouble();
          });
        }
      });
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: false,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: ThemeConfig.primaryColor,
            ),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: ThemeConfig.primaryColor,
          handleColor: ThemeConfig.primaryColor,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: ThemeConfig.primaryColor.withOpacity(0.5),
        ),
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    
    // Restore orientations and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ThemeConfig.primaryColor))
          : Stack(
              children: [
                // Video Player
                Center(
                  child: Chewie(controller: _chewieController!),
                ),
                
                // Custom Controls Overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                      });
                    },
                    child: AnimatedOpacity(
                      opacity: _isFullScreen ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          children: [
                            // Top controls
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.workout.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                    onPressed: () {
                                      // Show options
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Bottom controls
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // Progress bar
                                  SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                      activeTrackColor: ThemeConfig.primaryColor,
                                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                                      thumbColor: ThemeConfig.primaryColor,
                                    ),
                                    child: Slider(
                                      value: _currentPosition,
                                      min: 0,
                                      max: _videoDuration,
                                      onChanged: (value) {
                                        setState(() {
                                          _currentPosition = value;
                                        });
                                      },
                                      onChangeEnd: (value) {
                                        _videoPlayerController.seekTo(
                                          Duration(milliseconds: value.toInt()),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // Time indicators and controls
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        // Current time
                                        Text(
                                          _formatDuration(_videoPlayerController.value.position),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Rewind button
                                        IconButton(
                                          icon: const Icon(Icons.replay_10, color: Colors.white),
                                          onPressed: () {
                                            final newPosition = _videoPlayerController.value.position -
                                                const Duration(seconds: 10);
                                            _videoPlayerController.seekTo(newPosition);
                                          },
                                        ),
                                        
                                        // Play/Pause button
                                        IconButton(
                                          iconSize: 40,
                                          icon: Icon(
                                            _videoPlayerController.value.isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_videoPlayerController.value.isPlaying) {
                                                _videoPlayerController.pause();
                                              } else {
                                                _videoPlayerController.play();
                                              }
                                            });
                                          },
                                        ),
                                        
                                        // Forward button
                                        IconButton(
                                          icon: const Icon(Icons.forward_10, color: Colors.white),
                                          onPressed: () {
                                            final newPosition = _videoPlayerController.value.position +
                                                const Duration(seconds: 10);
                                            _videoPlayerController.seekTo(newPosition);
                                          },
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Total duration
                                        Text(
                                          _formatDuration(_videoPlayerController.value.duration),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: screenSize.height * 0.02),
                                  
                                  // Additional controls
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildControlButton(Icons.speed, 'Speed'),
                                      _buildControlButton(Icons.subtitles, 'Subtitles'),
                                      _buildControlButton(Icons.fit_screen, 'Fit'),
                                      _buildControlButton(Icons.hd, 'Quality'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildControlButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
