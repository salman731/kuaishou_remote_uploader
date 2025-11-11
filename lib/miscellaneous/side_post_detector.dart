// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'package:path_provider/path_provider.dart';
//
// class SidePoseDetector {
//   final PoseDetector _poseDetector = PoseDetector(
//     options: PoseDetectorOptions(
//       mode: PoseDetectionMode.single, // Single image mode
//     ),
//   );
//
//   Future<bool> isSidePose(File imageFile) async {
//     try {
//       final inputImage = InputImage.fromFile(imageFile);
//       final poses = await _poseDetector.processImage(inputImage);
//
//       if (poses.isEmpty) return false;
//
//       final pose = poses.first; // Using the first detected pose
//
//       // Get required landmarks
//       final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
//       final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
//       final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
//       final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
//
//       // Check if landmarks are detected with sufficient confidence
//       if (!_isLandmarkValid(leftShoulder) ||
//           !_isLandmarkValid(rightShoulder) ||
//           !_isLandmarkValid(leftHip) ||
//           !_isLandmarkValid(rightHip)) {
//         return false;
//       }
//
//       // Calculate normalized differences (0-1 range)
//       final shoulderXDifference = (leftShoulder!.x - rightShoulder!.x).abs();
//       final shoulderYDifference = (leftShoulder.y - rightShoulder.y).abs();
//       final hipXDifference = (leftHip!.x - rightHip!.x).abs();
//
//       // Calculate ratios
//       final shoulderRatio = shoulderXDifference / shoulderYDifference;
//       final hipShoulderConsistency = (shoulderXDifference - hipXDifference).abs();
//
//       // Side pose conditions:
//       // 1. Shoulders are vertically aligned (small x difference relative to y)
//       // 2. Hips are also vertically aligned
//       // 3. Shoulder and hip x positions are consistent
//       print("shoulderRatio : $shoulderRatio");
//       print("hipXDifference : $hipXDifference");
//       print("hipShoulderConsistency : $hipShoulderConsistency");
//       return shoulderRatio < 5.0;
//     } catch (e) {
//       debugPrint('Pose detection error: $e');
//       return false;
//     }
//   }
//
//   bool _isLandmarkValid(PoseLandmark? landmark) {
//     // Consider landmark valid if detected with at least 70% confidence
//     return landmark != null && landmark.likelihood > 0.7;
//   }
//
//   Future<void> close() async {
//     await _poseDetector.close();
//   }
//
//   Future<File> loadAssetAsFile(String assetPath) async {
//     final byteData = await rootBundle.load(assetPath);
//     final tempDir = await getTemporaryDirectory();
//     final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
//     await tempFile.writeAsBytes(byteData.buffer.asUint8List());
//     return tempFile;
//   }
// }
