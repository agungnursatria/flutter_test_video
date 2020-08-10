import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_camera/bloc/bloc.dart';
import 'package:flutter_test_camera/initiator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Home()));
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraAppInitiator _i;

  @override
  void initState() {
    super.initState();
    _i = CameraAppInitiator()..init();
  }

  @override
  void dispose() {
    _i.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _i.cameraBloc,
      listener: (context, state) {
        if (state is CameraRunning) {
          if (state.selectedCamera == null) {
            _i.onSelectCamera(
              cameraDescription: state.cameras.firstWhere(
                (element) => element.lensDirection == CameraLensDirection.front,
              ),
              onMounted: () {
                if (mounted) setState(() {});
              },
              enableAudio: true,
            );
          }
          if (!state.isRecording && state.recordedFilePath != null) {
            _i.onRecordSuccess(context, state.recordedFilePath);
          }
        }
      },
      builder: (context, state) {
        bool cameraInitialized = _i.controller?.value?.isInitialized ?? false;
        bool isRecording = _i.controller?.value?.isRecordingVideo ?? false;
        double aspectRatio = _i.controller?.value?.aspectRatio ?? 0;
        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: _appBar(context),
          body: cameraInitialized && state is CameraRunning
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: aspectRatio,
                        child: CameraPreview(_i.controller),
                      ),
                      _cameraRecordButton(isRecording),
                    ],
                  ),
                )
              : _loadingWidget(),
        );
      },
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Video Camera',
        style:
            Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _loadingWidget() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _cameraRecordButton(bool isRecording) {
    return Container(
      margin: EdgeInsets.all(24.0),
      height: 80,
      width: 80,
      child: FlatButton(
        onPressed: isRecording ? _i.onStopRecord : _i.onStartRecord,
        child: Container(),
        color: isRecording ? Colors.red[800] : Colors.grey[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
            width: 10.0,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
