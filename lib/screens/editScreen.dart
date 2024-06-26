import 'dart:io';
import 'package:fyp_automated_video_editing_app/screens/videoPickerScreen.dart';

import '../editor/crop_page.dart';
import '../editor/export_service.dart';
import '../editor/widgets/export_result.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart'
    show OpacityTransition, SwipeTransition, AnimatedInteractiveViewer;
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../component/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.file});
  final File file;
  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 30),
  );

  @override
  void initState(){
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _controller
         .initialize()
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
    super.initState();
  }


  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (_) => AlertDialog(
        title: ValueListenableBuilder(
          valueListenable: _exportingProgress,
          builder: (_, double value, __) => Text(
            "Exporting video ${(value * 100).ceil()}%",
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }


  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  Future<void> _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    _showExportDialog();
    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    try {
      await ExportService.runFFmpegCommand(
        await config.getExecuteConfig(),
        onProgress: (stats) {
          _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
        },
        onError: (e, s) {
          _showErrorSnackBar("Error on export video :(");
          _isExporting.value = false; // Update state if error occurs
          Navigator.pop(context); // Dismiss the dialog on error
        },
        onCompleted: (file) async {
          _isExporting.value = false;
          Navigator.pop(context);

          // Save the exported video to the gallery
          final appDir = await getTemporaryDirectory();
          final savePath = '${appDir.path}/exported_video.mp4'; // Define the save path

          // Copy the exported file to the desired gallery location
          final File newFile = await File(file.path).copy(savePath);

          // Use a plugin like `gallery_saver` to save the video to the gallery
          final bool? isSaved = await GallerySaver.saveVideo(newFile.path);
          if (isSaved ?? false) {
            // Video saved successfully
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (_) => VideoResultPopup(video: newFile),
            );
          } else {
            // Video saving failed or returned null
            _showErrorSnackBar("Failed to save video to the gallery");
          }
        },
      );
    } catch (e) {
      // Handle exceptions or errors if needed
      _showErrorSnackBar("An error occurred during export");
      _isExporting.value = false; // Update state if error occurs
      Navigator.pop(context); // Dismiss the dialog on error
    }
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 20, 21, 24),
      body: SafeArea(
        child: Row(
          children: [
            // This is the First Left side of the main row
            Container(
              //color: Colors.red,
              height: MediaQuery.of(context).size.height,
              width: 60,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(Icons.exit_to_app,size:20.0 , color: Colors.white,),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: IconButton(
                            icon: Icon(Icons.undo_rounded,size:25.0 , color: Colors.white,),
                          onPressed: () =>
                              _controller.rotate90Degrees(RotateDirection.right),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: IconButton(
                            icon:const Icon(Icons.redo_rounded,size:25.0 , color: Colors.white,),
                          onPressed: () =>
                              _controller.rotate90Degrees(RotateDirection.left),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: IconButton(
                            icon:const Icon(Icons.crop,size:25.0 , color: Colors.white,),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => CropPage(controller: _controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: IconButton(
                            icon: Icon(Icons.expand,size:25.0 , color: Colors.white,),
                            onPressed:_exportCover
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Container(
                        color: ShadowColor,
                        width: 55,
                        height: 45,
                        child: IconButton(
                            icon: Icon(Icons.view_timeline,size:25.0 , color: Colors.white,),
                            onPressed: () {}
                        ),
                      ),
                    ),

                    
                  ],
                ),
              ),
            ),

            Expanded(
              child: Container(
                //color: Colors.blue,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Expanded(
                      flex:2,
                      child: Row(
                        children: [
                          Expanded(
                            flex:2,
                            child:  Stack(
                              alignment: Alignment.center,
                              children: [
                                CropGridViewer.preview(
                                    controller: _controller),
                                AnimatedBuilder(
                                  animation: _controller.video,
                                  builder: (_, __) => AnimatedOpacity(
                                    opacity:
                                    _controller.isPlaying ? 0 : 1,
                                    duration: kThemeAnimationDuration,
                                    child: GestureDetector(
                                      onTap: _controller.video.play,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration:
                                        const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              //color: Colors.pink,
                              // This is where making controls
                              child: Column(
                                children: [
                                  Expanded(
                                      child:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () async{
                                          await _exportVideo();
                                        },
                                        child: CircleAvatar(
                                        radius: 20,
                                          backgroundColor: ShadowColor,
                                          child:const Image(
                                            image: AssetImage('assets/icon.png'),width: 25,height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  ),
                                  Expanded(
                                      flex:4,
                                      child: Container(

                                        // editing options wheel
                                        //color: Colors.yellow,
                                        child: _controls(context),

                                      )
                                  ),
                                  Expanded(
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: (){},
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: ShadowColor,
                                                    child:const Image(
                                                      image: AssetImage('assets/store2.png'),width: 25,height: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: (){},
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: ShadowColor,
                                                    child:const Image(
                                                      image: AssetImage('assets/play1.png'),width: 25,height: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                  
                                ],
                              ),


                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      //TimeLine

                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: _trimSlider(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())),
                style:const TextStyle(color: Colors.white),),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim),
                    style:const TextStyle(color: Colors.white),),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim),
                    style:const TextStyle(color: Colors.white),),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 10),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 2),
          ),
        ),
      )
    ];
  }
}
Widget _controls(BuildContext context){
  return SizedBox(
      width: 145,
      height: 145,

      child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                left: 0,
                child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color : Color.fromRGBO(57, 60, 74, 1),
                      border : Border.all(
                        color: Color.fromRGBO(13, 14, 15, 1),
                        width: 2,
                      ),
                      borderRadius : BorderRadius.all(Radius.elliptical(140, 140)),
                    )
                )
            ),Positioned(
                top: 38.5,
                left: 42,
                child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color : Color.fromRGBO(255, 90, 92, 1),
                      border : Border.all(
                        color: Color.fromRGBO(13, 14, 15, 1),
                        width: 3,
                      ),
                      borderRadius : BorderRadius.all(Radius.elliptical(56, 56)),
                    )
                )
            ),Positioned(
                top: 27.99993896484375,
                left: 50,
                child: Transform.rotate(
                  angle: -37.476177031803346 * (math.pi / 180),
                  child: Divider(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      thickness: 2
                  )
                  ,
                )
            ),Positioned(
                top: 94.5,
                left: 98,
                child: Transform.rotate(
                  angle: -37.476177031803346 * (math.pi / 180),
                  child: Divider(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      thickness: 2
                  )
                  ,
                )
            ),Positioned(
                top: 113.81488037109375,
                left: 23.800003051757812,
                child: Transform.rotate(
                  angle: 46.880307130031774 * (math.pi / 180),
                  child: Divider(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      thickness: 2
                  )
                  ,
                )
            ),Positioned(
                top: 43.81488037109375,
                left: 98,
                child: Transform.rotate(
                  angle: 46.880307130031774 * (math.pi / 180),
                  child: Divider(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      thickness: 10
                  )
                  ,
                )
            ),Positioned(
                top: 50.16839599609375,
                left: 53.846153259277344,
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                      width: 31.5,
                      height: 32.78863525390625,
                      decoration: BoxDecoration(
                        image : DecorationImage(
                            image: AssetImage('assets/lens.png'),
                            fit: BoxFit.fitWidth
                        ),
                      )
                  ),
                )
            ),Positioned(
                top: 6.8760986328125,
                left: 58,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const VideoEditorExample()));
                  },
                  child: Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        image : DecorationImage(
                            image: AssetImage('assets/Video.png'),
                            fit: BoxFit.fitWidth
                        ),
                      )
                  ),
                )
            ),Positioned(
                top: 55.04693603515625,
                left: 100,
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        image : DecorationImage(
                            image: AssetImage('assets/music.png'),
                            fit: BoxFit.fitWidth
                        ),
                      )
                  ),
                )
            ),Positioned(
                top: 57,
                left: 15,
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        image : DecorationImage(
                            image: AssetImage('assets/Layers.png'),
                            fit: BoxFit.fitWidth
                        ),
                      )
                  ),
                )
            ),Positioned(
                top: 98.872314453125,
                left: 58,
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        image : DecorationImage(
                            image: AssetImage('assets/Mic.png'),
                            fit: BoxFit.fitWidth
                        ),
                      )
                  ),
                )
            ),Positioned(
                top: 80,
                left: 15,
                child: Text('Layer', textAlign: TextAlign.center, style: TextStyle(
                    color: Color.fromRGBO(250, 250, 250, 1),

                    fontSize: 8,
                    letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1
                ),)
            ),Positioned(
                top: 125,
                left: 66,
                child: Text('REC', textAlign: TextAlign.center, style: TextStyle(
                    color: Color.fromRGBO(250, 250, 250, 1),
                    fontSize: 8,
                    letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1
                ),)
            ),Positioned(
                top: 79.09991455078125,
                left: 105,
                child: Text('Audio', textAlign: TextAlign.center, style: TextStyle(
                    color: Color.fromRGBO(250, 250, 250, 1),
                    fontSize: 8,
                    letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1
                ),)
            ),Positioned(
                top: 29,
                left: 60,
                child: Text('MEDIA', textAlign: TextAlign.center, style: TextStyle(
                    color: Color.fromRGBO(250, 250, 250, 1),
                    fontSize: 8,
                    letterSpacing: 0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1
                ),)
            ),
          ]
      )
  );
}





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => VideoResultPopup(video: file),
        );
      },
    );
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _topNavBar(),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: TabBarView(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CropGridViewer.preview(
                                        controller: _controller),
                                    AnimatedBuilder(
                                      animation: _controller.video,
                                      builder: (_, __) => AnimatedOpacity(
                                        opacity:
                                        _controller.isPlaying ? 0 : 1,
                                        duration: kThemeAnimationDuration,
                                        child: GestureDetector(
                                          onTap: _controller.video.play,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration:
                                            const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                CoverViewer(controller: _controller)
                              ],
                            ),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  Icons.content_cut)),
                                          Text('Trim')
                                        ]),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(5),
                                            child:
                                            Icon(Icons.video_label)),
                                        Text('Cover')
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: _trimSlider(),
                                      ),
                                      _coverSelection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: _isExporting,
                            builder: (_, bool export, Widget? child) =>
                                AnimatedSize(
                                  duration: kThemeAnimationDuration,
                                  child: export ? child : null,
                                ),
                            child: AlertDialog(
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) => Text(
                                  "Exporting video ${(value * 100).ceil()}%",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotate unclockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: _controller),
                  ),
                ),
                icon: const Icon(Icons.crop),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon: const Icon(Icons.save),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: _exportCover,
                    child: const Text('Export cover'),
                  ),
                  PopupMenuItem(
                    onTap: _exportVideo,
                    child: const Text('Export video'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

