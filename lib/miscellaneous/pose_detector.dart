// import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
//
// class PoseDetector {
//   late Interpreter interpreter;
//
//   Future<void> loadModel() async {
//     try {
//       interpreter = await Interpreter.fromAsset('movenet.tflite');
//     } catch (e) {
//       print('Failed to load model: $e');
//     }
//   }
//
//   Future<List<double>?> detectSidePose(File image) async {
//     // Preprocess image
//     img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
//     imageInput = img.copyResize(imageInput!, width: 192, height: 192);
//
//     // Normalize pixel values
//     var input = List.filled(1 * 192 * 192 * 3, 0).reshape([1, 192, 192, 3]);
//     for (int y = 0; y < 192; y++) {
//       for (int x = 0; x < 192; x++) {
//         var pixel = imageInput.getPixel(x, y);
//         // Correct way to access color channels:
//         input[0][y][x][0] = (pixel.r - 127.5) / 127.5;   // Red channel
//         input[0][y][x][1] = (pixel.g - 127.5) / 127.5;   // Green channel
//         input[0][y][x][2] = (pixel.b - 127.5) / 127.5;   // Blue channel
//       }
//     }
//
//     // Run inference
//     var output = List.filled(1 * 1 * 17 * 3, 0).reshape([1, 1, 17, 3]);
//     interpreter.run(input, output);
//
//     // Analyze keypoints to determine if it's a side pose
//     bool isSidePose = _isSideView(output[0][0]);
//
//     return isSidePose ? output[0][0] : null;
//   }
//
//   bool _isSideView(List<List<double>> keypoints) {
//     // Keypoints indices (for MoveNet)
//     const leftShoulder = 5;
//     const rightShoulder = 6;
//     const leftHip = 11;
//     const rightHip = 12;
//
//     // Calculate shoulder and hip visibility and positions
//     double shoulderXDiff = (keypoints[leftShoulder][0] - keypoints[rightShoulder][0]).abs();
//     double hipXDiff = (keypoints[leftHip][0] - keypoints[rightHip][0]).abs();
//
//     // Side view typically has overlapping shoulders/hips in x-axis
//     return shoulderXDiff < 0.2 && hipXDiff < 0.2;
//   }
//
//   void dispose() {
//     interpreter.close();
//   }
// }