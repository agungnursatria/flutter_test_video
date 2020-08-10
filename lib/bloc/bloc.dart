import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial());

  @override
  Stream<CameraState> mapEventToState(
    CameraEvent event,
  ) async* {
    if (event is GetAvailableCameras) {
      yield* _mapGetAvailableCameraToState(event);
    } else if (event is SelectCamera) {
      yield* _mapSelectCameraToState(event);
    } else if (event is StartRecord) {
      yield* _mapStartRecordToState(event);
    } else if (event is StopRecord) {
      yield* _mapStopRecordToState(event);
    }
  }

  Stream<CameraState> _mapStopRecordToState(
    StopRecord event,
  ) async* {
    if (state is! CameraRunning) return;
    CameraRunning _state = state as CameraRunning;
    yield _state.copyWith(isRecording: false);
  }

  Stream<CameraState> _mapStartRecordToState(
    StartRecord event,
  ) async* {
    if (state is! CameraRunning) return;
    CameraRunning _state = state as CameraRunning;
    yield _state.copyWith(
      recordedFilePath: event.filePath,
      isRecording: true,
    );
  }

  Stream<CameraState> _mapGetAvailableCameraToState(
    GetAvailableCameras event,
  ) async* {
    List<CameraDescription> cameras = await availableCameras();
    if (cameras == null || cameras.isEmpty) {
      yield CameraError(errorMessage: 'Kamera tidak terdeteksi...');
      return;
    }
    yield CameraRunning(cameras: cameras);
  }

  Stream<CameraState> _mapSelectCameraToState(SelectCamera event) async* {
    if (state is! CameraRunning) return;
    CameraRunning _state = state as CameraRunning;
    yield _state.copyWith(
      selectedCamera: _state.cameras.firstWhere(
        (element) => element.lensDirection == event.direction,
      ),
    );
  }
}
