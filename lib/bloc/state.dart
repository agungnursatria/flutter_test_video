part of 'bloc.dart';

abstract class CameraState extends Equatable {
  CameraState([mProps = const []]) : this._mProps = mProps;
  final List _mProps;
  @override
  List<Object> get props => this._mProps;
}

class CameraInitial extends CameraState {}

class CameraRunning extends CameraState {
  final List<CameraDescription> cameras;
  final CameraDescription selectedCamera;
  final String recordedFilePath;
  final bool isRecording;

  CameraRunning({
    this.cameras,
    this.selectedCamera,
    this.recordedFilePath,
    this.isRecording = false,
  }) : super([
          cameras,
          selectedCamera,
          recordedFilePath,
          isRecording,
        ]);

  CameraRunning copyWith({
    List<CameraDescription> cameras,
    CameraDescription selectedCamera,
    String recordedFilePath,
    bool isRecording,
  }) {
    return CameraRunning(
      cameras: cameras ?? this.cameras,
      selectedCamera: selectedCamera ?? this.selectedCamera,
      recordedFilePath: recordedFilePath ?? this.recordedFilePath,
      isRecording: isRecording ?? false,
    );
  }
}

class CameraError extends CameraState {
  final String errorMessage;

  CameraError({
    this.errorMessage,
  }) : super([
          errorMessage,
        ]);
}
