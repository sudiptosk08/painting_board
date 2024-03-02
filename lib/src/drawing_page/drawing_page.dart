import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:painter_app/main.dart';
import 'package:painter_app/src/drawing_canvas/drawing_canvas.dart';
import 'package:painter_app/src/drawing_canvas/models/drawing_mode.dart';
import 'package:painter_app/src/drawing_canvas/models/sketch.dart';
import 'package:painter_app/src/drawing_canvas/widgets/canvas_side_bar.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: kCanvasColor,
              width: double.maxFinite,
              height: double.maxFinite,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
                backgroundImage: backgroundImage,
              ),
            ),
            Positioned(
              // left: -5,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animationController),
                child: CanvasSideBar(
                  drawingMode: drawingMode,
                  selectedColor: selectedColor,
                  strokeSize: strokeSize,
                  eraserSize: eraserSize,
                  currentSketch: currentSketch,
                  allSketches: allSketches,
                  canvasGlobalKey: canvasGlobalKey,
                  filled: filled,
                  polygonSides: polygonSides,
                  backgroundImage: backgroundImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


