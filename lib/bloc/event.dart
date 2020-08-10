part of 'bloc.dart';

abstract class CameraEvent {}

class GetAvailableCameras extends CameraEvent {}

class SelectCamera extends CameraEvent {
  final CameraLensDirection direction;

  SelectCamera({
    this.direction,
  });
}

class StartRecord extends CameraEvent {
  final String filePath;
  StartRecord({this.filePath});
}

class StopRecord extends CameraEvent {}
