import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:works_app/components/colors.dart';

import '../../components/size_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../../models/chat/chat_view_modal.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final bool isLast;

  const ChatBubble({
    super.key,
    required this.text,
    this.isSender = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isSender) const Spacer(),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSender
                        ? const Color(0xFF276bfd)
                        : const Color(0xFF343145)),
                padding: const EdgeInsets.only(
                    bottom: 9, top: 8, left: 14, right: 12),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WaveBubble extends StatefulWidget {
  final bool isSender;
  final String? audioUrl;
  final bool? downloaded;
  final MessageState messageState;
  final bool isUploading;
  final VoidCallback? onRetry;

  const WaveBubble({
    super.key,
    required this.audioUrl,
    this.isSender = false,
    this.downloaded = false,
    this.messageState = MessageState.sent,
    this.isUploading = false,
    this.onRetry,
  });

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  static AudioPlayer? _globalAudioPlayer;
  late AudioPlayer _audioPlayer;
  late PlayerController _playerController;
  bool isPlaying = false;
  bool isDownloading = false;
  String? localFilePath;
  double progress = 0.0;
  final List<double> waveformData = [];

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: COLORS.primary,
    liveWaveColor: COLORS.primary,
    spacing: 4,
    waveThickness: 1.25,
    backgroundColor: COLORS.neutralDark,
    waveCap: StrokeCap.square,
    showSeekLine: true,
  );

  @override
  void initState() {
    super.initState();
    try {
      _audioPlayer = AudioPlayer();
      _playerController = PlayerController();

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) async {
        try {
          final duration = await _audioPlayer.duration;
          if (duration != null && position.inMilliseconds > 0) {
            if (mounted) {
              setState(() {
                progress = position.inMilliseconds / duration.inMilliseconds;
              });
            }
          }

          if (duration != null && position >= duration) {
            if (mounted) {
              setState(() {
                isPlaying = false;
                progress = 0.0;
              });
            }
            await _audioPlayer.stop();
          }
        } catch (e) {
          debugPrint("Audio position stream error: $e");
        }
      });

      _checkLocalFile();
      if (widget.downloaded == true) {
        _downloadAudio();
      }
    } catch (e) {
      debugPrint("WaveBubble initState error: $e");
    }
  }

  Future<void> _checkLocalFile() async {
    if (widget.audioUrl == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/audio_${widget.audioUrl.hashCode}.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            localFilePath = filePath;
          });
        }
        await _preparePlayer();
      }
    } catch (e) {
      debugPrint("Error checking local file: $e");
    }
  }

  Future<void> _downloadAudio() async {
    if (widget.audioUrl == null || isDownloading) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/audio_${widget.audioUrl.hashCode}.mp3';
      final file = File(filePath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            localFilePath = filePath;
          });
        }
        await _preparePlayer();
        return;
      }

      if (mounted) {
        setState(() {
          isDownloading = true;
        });
      }

      final response = await http.get(Uri.parse(widget.audioUrl!));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            localFilePath = filePath;
          });
        }
        await _preparePlayer();
      } else {
        debugPrint("Failed to download audio: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error downloading audio: $e");
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  Future<void> _preparePlayer() async {
    if (localFilePath != null) {
      try {
        await _audioPlayer.setFilePath(localFilePath!);
        _playerController.preparePlayer(path: localFilePath!);
      } catch (e) {
        debugPrint("Error preparing player: $e");
      }
    }
  }

  void _togglePlayPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_globalAudioPlayer != null && _globalAudioPlayer != _audioPlayer) {
          await _globalAudioPlayer!.stop();
        }
        _globalAudioPlayer = _audioPlayer;
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error toggling play/pause: $e");
    }
  }

  @override
  void dispose() {
    try {
      _audioPlayer.dispose();
      _playerController.dispose();
    } catch (e) {
      debugPrint("Error disposing audio player: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.audioUrl != null
        ? Align(
            alignment:
                widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: _buildAudioContent(),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildAudioContent() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: widget.isUploading || widget.messageState == MessageState.sending
          ? Row(
              key: ValueKey('uploading'),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(COLORS.primary),
                  strokeWidth: 2,
                ),
                SizedBox(width: SizeConfig.blockWidth * 3),
                Text(
                  'Uploading...',
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 2.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            )
          : widget.messageState == MessageState.failed
              ? Row(
                  key: ValueKey('failed'),
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: widget.onRetry,
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.blockWidth * 1),
                        decoration: BoxDecoration(
                          color: COLORS.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: COLORS.white,
                          size: SizeConfig.blockWidth * 4,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockWidth * 2),
                    Text(
                      'Retry',
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 2.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                )
              : _buildNormalAudioContent(),
    );
  }

  Widget _buildNormalAudioContent() {
    // Show downloading state
    if (localFilePath == null) {
      return isDownloading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: COLORS.primary,
                    size: SizeConfig.blockHeight * 3,
                  ),
                ),
                SizedBox(width: SizeConfig.blockWidth * 3),
                Text(
                  'downloading....',
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 2.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _downloadAudio,
                  child: Icon(
                    Icons.download,
                    color: COLORS.neutralDark,
                    size: SizeConfig.blockHeight * 3.25,
                  ),
                ),
                SizedBox(width: SizeConfig.blockWidth),
                Text(
                  'audio.mp3',
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 2.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            );
    }

    // Show normal audio player
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _togglePlayPause,
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_circle,
            color: COLORS.neutralDark,
            size: SizeConfig.blockWidth * 8,
          ),
        ),
        SizedBox(width: SizeConfig.blockWidth * 1.5),
        AudioFileWaveforms(
          size: Size(SizeConfig.blockWidth * 40, SizeConfig.blockHeight * 3),
          playerController: _playerController,
          waveformType: WaveformType.fitWidth,
          playerWaveStyle: playerWaveStyle,
          continuousWaveform: true,
          enableSeekGesture: true,
        ),
      ],
    );
  }
}

// class WaveBubble extends StatefulWidget {
//   final bool isSender;
//   final String? audioUrl;
//   final Function(PlayerController)? onPlay; // Callback to notify parent
//
//   const WaveBubble({
//     super.key,
//     required this.audioUrl,
//     this.isSender = false,
//     this.onPlay,
//   });
//
//   @override
//   State<WaveBubble> createState() => _WaveBubbleState();
// }
//
// class _WaveBubbleState extends State<WaveBubble> {
//   late PlayerController controller;
//   StreamSubscription<PlayerState>? playerStateSubscription;
//   bool isPlaying = false;
//   bool isDownloading = false;
//   String? localFilePath;
//
//   static PlayerController?
//   _currentlyPlayingController; // Keep track of playing controller
//
//   final playerWaveStyle = const PlayerWaveStyle(
//     fixedWaveColor: COLORS.neutralDark,
//     liveWaveColor: COLORS.neutralDark,
//     spacing: 6,
//     waveThickness: 1,
//     backgroundColor: COLORS.neutralDark,
//     waveCap: StrokeCap.square,
//     showSeekLine: true,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     controller = PlayerController();
//     _checkLocalFile();
//
//     playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
//       setState(() {
//         isPlaying = state.isPlaying;
//       });
//
//       if (!state.isPlaying && _currentlyPlayingController == controller) {
//         _currentlyPlayingController = null; // Reset if audio stops
//       }
//     });
//   }
//
//   Future<void> _checkLocalFile() async {
//     if (widget.audioUrl == null) return;
//
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/audio_${widget.audioUrl.hashCode}.mp3';
//     final file = File(filePath);
//
//     if (await file.exists()) {
//       debugPrint("🟢 Audio file found locally: $filePath");
//       setState(() {
//         localFilePath = filePath;
//       });
//       await _preparePlayer();
//     } else {
//       debugPrint("❌ Audio file not found, requires download.");
//     }
//   }
//
//   Future<void> _downloadAudio() async {
//     if (widget.audioUrl == null || isDownloading) return;
//
//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/audio_${widget.audioUrl.hashCode}.mp3';
//     final file = File(filePath);
//
//     if (await file.exists()) {
//       debugPrint("🟢 Audio already exists: $filePath");
//       setState(() {
//         localFilePath = filePath;
//       });
//       await _preparePlayer();
//       return;
//     }
//
//     setState(() {
//       isDownloading = true;
//     });
//
//     try {
//       debugPrint("📥 Downloading audio: ${widget.audioUrl}");
//       final response = await http.get(Uri.parse(widget.audioUrl!));
//
//       if (response.statusCode == 200) {
//         await file.writeAsBytes(response.bodyBytes);
//         debugPrint("✅ Download complete: $filePath");
//
//         if (await file.exists()) {
//           setState(() {
//             localFilePath = filePath;
//           });
//           await _preparePlayer();
//         } else {
//           debugPrint("❌ File not found after download!");
//         }
//       } else {
//         debugPrint("❌ Failed to download audio: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("❌ Error downloading audio: $e");
//     }
//
//     setState(() {
//       isDownloading = false;
//     });
//   }
//
//   Future<void> _preparePlayer() async {
//     if (localFilePath == null) return;
//
//     try {
//       await controller.preparePlayer(
//         path: localFilePath!,
//         shouldExtractWaveform: true,
//         noOfSamples: 100,
//       );
//       debugPrint("🎵 Audio ready to play: $localFilePath");
//     } catch (e) {
//       debugPrint("❌ Error preparing audio: $e");
//     }
//   }
//
//   // void _togglePlayPause() async {
//   //   if (isPlaying) {
//   //     await controller.pausePlayer();
//   //     return;
//   //   }
//   //
//   //   // Stop previously playing audio
//   //   if (_currentlyPlayingController != null &&
//   //       _currentlyPlayingController != controller) {
//   //     await _currentlyPlayingController!.pausePlayer();
//   //   }
//   //
//   //   await controller.startPlayer();
//   //   controller.setFinishMode(finishMode: FinishMode.stop);
//   //
//   //   _currentlyPlayingController = controller; // Set current controller
//   //
//   //   // Notify parent widget (if applicable)
//   //   widget.onPlay?.call(controller);
//   // }
//
//   void _togglePlayPause() async {
//     if (isPlaying) {
//       await controller.pausePlayer();
//       return;
//     }
//
//     if (_currentlyPlayingController != null &&
//         _currentlyPlayingController != controller) {
//       await _currentlyPlayingController!.pausePlayer();
//     }
//
//     if (localFilePath != null) {
//       await _preparePlayer(); // Ensure player is ready before playing
//     }
//
//     await controller.startPlayer();
//     controller.setFinishMode(finishMode: FinishMode.stop);
//
//     _currentlyPlayingController = controller;
//     widget.onPlay?.call(controller);
//   }
//
//
//   @override
//   void dispose() {
//     playerStateSubscription?.cancel();
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.audioUrl != null
//         ? Align(
//       alignment:
//       widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           vertical: SizeConfig.blockWidth * 0.2,
//           horizontal: SizeConfig.blockWidth * 0.5,
//         ),
//         child: Row(
//           children: [
//             if (localFilePath == null)
//               isDownloading
//                   ? Center(
//                 child: LoadingAnimationWidget.hexagonDots(
//                   color: COLORS.primary,
//                   size: SizeConfig.blockHeight * 3,
//                 ),
//               )
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   InkWell(
//                       onTap: _downloadAudio,
//                       child: Icon(
//                         Icons.download,
//                         color: COLORS.neutralDark,
//                         size: SizeConfig.blockHeight * 3.5,
//                       )),
//                   SizedBox(width: SizeConfig.blockWidth,),
//                   Text(
//                     'audio.mp3',
//                     style: TextStyle(
//                       color: COLORS.neutralDarkOne,
//                       fontSize: SizeConfig.blockWidth * 2.5,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: "Poppins",
//                     ),
//                   ),
//                 ],
//               ),
//             if (localFilePath != null) ...[
//               InkWell(
//                 onTap: _togglePlayPause,
//                 child: Icon(
//                   isPlaying ? Icons.pause : Icons.play_circle,
//                   color: COLORS.neutralDark,
//                   size: SizeConfig.blockWidth * 8,
//                 ),
//               ),
//               AudioFileWaveforms(
//                 size: Size(SizeConfig.blockWidth * 40,
//                     SizeConfig.blockHeight * 3),
//                 playerController: controller,
//                 waveformType: WaveformType.fitWidth,
//                 playerWaveStyle: playerWaveStyle,
//                 continuousWaveform: true,
//                 enableSeekGesture: true,
//               ),
//             ],
//           ],
//         ),
//       ),
//     )
//         : const SizedBox.shrink();
//   }
// }
