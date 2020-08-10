import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_camera/bloc/bloc.dart';
import 'package:flutter_test_camera/video_preview.dart';
import 'package:path_provider/path_provider.dart';

class CameraAppInitiator {
  CameraBloc _cameraBloc;
  CameraController _controller;

  /* ----------- PARAMETER ----------- */
  CameraController get controller => _controller;
  CameraBloc get cameraBloc => _cameraBloc;

  /* ----------- FUNCTION ----------- */
  void init() {
    _cameraBloc = CameraBloc();
    _cameraBloc.add(GetAvailableCameras());
  }

  void dispose() {
    _cameraBloc.close();
    _controller?.dispose();
  }

  void updateCameraOnChangeLifecycle(
    AppLifecycleState state, {
    bool isMounted = false,
    VoidCallback onMounted,
    bool enableAudio = false,
  }) {
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        onSelectCamera(
          cameraDescription: _controller.description,
          onMounted: onMounted,
          enableAudio: enableAudio,
        );
      }
    }
  }

  void onSelectCamera({
    CameraDescription cameraDescription,
    VoidCallback onMounted,
    bool enableAudio = false,
  }) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (onMounted != null) onMounted();
      if (controller.value.hasError) {
        debugPrint('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      _cameraBloc.add(SelectCamera(direction: cameraDescription.lensDirection));
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onStartRecord() {
    startRecording();
  }

  void onStopRecord() {
    stopRecording();
  }

  Future<void> stopRecording() async {
    if (_controller?.value?.isRecordingVideo != true) {
      return;
    }

    try {
      await _controller?.stopVideoRecording();
      _cameraBloc.add(StopRecord());
      debugPrint('Stop record');
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  Future<void> startRecording() async {
    if (_controller?.value?.isInitialized != true) {
      debugPrint('Error: select a camera first.');
      return;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (_controller?.value?.isRecordingVideo == true) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await _controller?.startVideoRecording(filePath);
      _cameraBloc.add(StartRecord(filePath: filePath));
      debugPrint('Start record');
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  void onRecordSuccess(BuildContext context, String recordedFilePath) {
    debugPrint('Record success');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreview(
          recordedFilePath,
        ),
      ),
    );
  }
}
