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

// class WaveBubble extends StatefulWidget {
//   final bool isSender;
//   final int? index;
//   final String? path;
//   final double? width;
//   final Directory appDirectory;
//
//   const WaveBubble({
//     super.key,
//     required this.appDirectory,
//     this.width,
//     this.index,
//     this.isSender = false,
//     this.path,
//   });
//
//   @override
//   State<WaveBubble> createState() => _WaveBubbleState();
// }
//
// class _WaveBubbleState extends State<WaveBubble> {
//   File? file;
//
//   late PlayerController controller;
//   late StreamSubscription<PlayerState> playerStateSubscription;
//
//   final playerWaveStyle = const PlayerWaveStyle(
//     fixedWaveColor: COLORS.primary,
//     liveWaveColor: COLORS.primary,
//     spacing: 6,
//     waveThickness: 1,backgroundColor: COLORS.primary,waveCap: StrokeCap.square
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     controller = PlayerController();
//     _preparePlayer();
//     playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
//       setState(() {});
//     });
//   }
//
//   void _preparePlayer() async {
//     if (widget.index != null) {
//       file = File('${widget.appDirectory.path}/audio${widget.index}.mp3');
//       await file?.writeAsBytes(
//           (await rootBundle.load('assets/audios/audio${widget.index}.mp3'))
//               .buffer
//               .asUint8List());
//     }
//     if (widget.index == null && widget.path == null && file?.path == null) {
//       return;
//     }
//     // Prepare player with extracting waveform if index is even.
//     controller.preparePlayer(
//       path: widget.path ?? file!.path,
//       shouldExtractWaveform: widget.index?.isEven ?? true,
//     );
//     // Extracting waveform separately if index is odd.
//     if (widget.index?.isOdd ?? false) {
//       controller
//           .extractWaveformData(
//             path: widget.path ?? file!.path,
//             noOfSamples:
//                 playerWaveStyle.getSamplesForWidth(widget.width ?? 200),
//           )
//           .then((waveformData) => debugPrint(waveformData.toString()));
//     }
//   }
//
//   @override
//   void dispose() {
//     playerStateSubscription.cancel();
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.path != null || file?.path != null
//         ? Align(
//             alignment:
//                 widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.only(
//                 bottom: SizeConfig.blockWidth,
//                 right: widget.isSender ? 0 : SizeConfig.blockWidth * 3,
//                 top: SizeConfig.blockWidth,
//               ),
//
//               // decoration: BoxDecoration(
//               //   borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3,),
//               //   color: widget.isSender
//               //       ? COLORS.neutralDarkTwo
//               //       : COLORS.primaryOne,
//               // ),
//               child: Row(
//                 children: [
//                   if (!controller.playerState.isStopped)
//                     IconButton(
//                       onPressed: () async {
//                         controller.playerState.isPlaying
//                             ? await controller.pausePlayer()
//                             : await controller.startPlayer();
//                         controller.setFinishMode(finishMode: FinishMode.loop);
//                       },
//                       icon: Icon(
//                         controller.playerState.isPlaying
//                             ? Icons.stop
//                             : Icons.play_circle,
//                         color: COLORS.neutralDark,size: SizeConfig.blockWidth*8,
//                       ),
//                       color: Colors.white,
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                     ),
//                   AudioFileWaveforms(
//                     size: Size(
//                         SizeConfig.blockWidth * 50, SizeConfig.blockHeight * 5),
//                     playerController: controller,
//                     waveformType: widget.index?.isOdd ?? false
//                         ? WaveformType.fitWidth
//                         : WaveformType.long,
//                     playerWaveStyle: playerWaveStyle,
//                     continuousWaveform: true,
//                     enableSeekGesture: true,
//                   ),
//                   if (widget.isSender)  SizedBox(width: SizeConfig.blockWidth*5),
//                 ],
//               ),
//             ),
//           )
//         : const SizedBox.shrink();
//   }
// }

class WaveBubble extends StatefulWidget {
  final bool isSender;
  final String? audioUrl;
  final Function(PlayerController)? onPlay; // Callback to notify parent

  const WaveBubble({
    super.key,
    required this.audioUrl,
    this.isSender = false,
    this.onPlay,
  });

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  late PlayerController controller;
  StreamSubscription<PlayerState>? playerStateSubscription;
  bool isPlaying = false;
  bool isDownloading = false;
  String? localFilePath;

  static PlayerController?
      _currentlyPlayingController; // Keep track of playing controller

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: COLORS.neutralDark,
    liveWaveColor: COLORS.neutralDark,
    spacing: 6,
    waveThickness: 1,
    backgroundColor: COLORS.neutralDark,
    waveCap: StrokeCap.square,
    showSeekLine: true,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();

    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state.isPlaying;
      });

      if (!state.isPlaying && _currentlyPlayingController == controller) {
        _currentlyPlayingController = null; // Reset if audio stops
      }
    });
  }

  Future<void> _downloadAudio() async {
    if (widget.audioUrl == null || isDownloading) return;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/audio_${widget.audioUrl.hashCode}.mp3';
    final file = File(filePath);

    if (await file.exists()) {
      debugPrint("🟢 Audio already exists: $filePath");
      setState(() {
        localFilePath = filePath;
      });
      await _preparePlayer();
      return;
    }

    setState(() {
      isDownloading = true;
    });

    try {
      debugPrint("📥 Downloading audio: ${widget.audioUrl}");
      final response = await http.get(Uri.parse(widget.audioUrl!));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint("✅ Download complete: $filePath");

        if (await file.exists()) {
          setState(() {
            localFilePath = filePath;
          });
          await _preparePlayer();
        } else {
          debugPrint("❌ File not found after download!");
        }
      } else {
        debugPrint("❌ Failed to download audio: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error downloading audio: $e");
    }

    setState(() {
      isDownloading = false;
    });
  }

  Future<void> _preparePlayer() async {
    if (localFilePath == null) return;

    try {
      await controller.preparePlayer(
        path: localFilePath!,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );
      debugPrint("🎵 Audio ready to play: $localFilePath");
    } catch (e) {
      debugPrint("❌ Error preparing audio: $e");
    }
  }

  // void _togglePlayPause() async {
  //   if (isPlaying) {
  //     await controller.pausePlayer();
  //     return;
  //   }
  //
  //   // Stop previously playing audio
  //   if (_currentlyPlayingController != null &&
  //       _currentlyPlayingController != controller) {
  //     await _currentlyPlayingController!.pausePlayer();
  //   }
  //
  //   await controller.startPlayer();
  //   controller.setFinishMode(finishMode: FinishMode.stop);
  //
  //   _currentlyPlayingController = controller; // Set current controller
  //
  //   // Notify parent widget (if applicable)
  //   widget.onPlay?.call(controller);
  // }

  void _togglePlayPause() async {
    if (isPlaying) {
      await controller.pausePlayer();
      return;
    }

    if (_currentlyPlayingController != null &&
        _currentlyPlayingController != controller) {
      await _currentlyPlayingController!.pausePlayer();
    }

    if (localFilePath != null) {
      await _preparePlayer(); // Ensure player is ready before playing
    }

    await controller.startPlayer();
    controller.setFinishMode(finishMode: FinishMode.stop);

    _currentlyPlayingController = controller;
    widget.onPlay?.call(controller);
  }


  @override
  void dispose() {
    playerStateSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.audioUrl != null
        ? Align(
            alignment:
                widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockWidth * 0.2,
                horizontal: SizeConfig.blockWidth * 0.5,
              ),
              child: Row(
                children: [
                  if (localFilePath == null)
                    isDownloading
                        ? Center(
                            child: LoadingAnimationWidget.hexagonDots(
                              color: COLORS.primary,
                              size: SizeConfig.blockHeight * 3,
                            ),
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
                                    size: SizeConfig.blockHeight * 3.5,
                                  )),
                              SizedBox(width: SizeConfig.blockWidth,),
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
                          ),
                  if (localFilePath != null) ...[
                    InkWell(
                      onTap: _togglePlayPause,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_circle,
                        color: COLORS.neutralDark,
                        size: SizeConfig.blockWidth * 8,
                      ),
                    ),
                    AudioFileWaveforms(
                      size: Size(SizeConfig.blockWidth * 40,
                          SizeConfig.blockHeight * 3),
                      playerController: controller,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: playerWaveStyle,
                      continuousWaveform: true,
                      enableSeekGesture: true,
                    ),
                  ],
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
