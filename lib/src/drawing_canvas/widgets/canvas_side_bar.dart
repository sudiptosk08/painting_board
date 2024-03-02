import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:painter_app/src/drawing_canvas/models/drawing_mode.dart';
import 'package:painter_app/src/drawing_canvas/models/sketch.dart';
import 'package:painter_app/src/drawing_canvas/widgets/border_gradeant_color.dart';
import 'package:painter_app/src/drawing_canvas/widgets/color_palette.dart';

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<ui.Image?> backgroundImage;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // PermissionUtil.requestAll();
    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    final scrollController = useScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Center(
              child: Wrap(
                children: [
                  GestureDetector(
                      onTap: allSketches.value.isNotEmpty
                          ? () => undoRedoStack.value.undo()
                          : null,
                      child: GradientBorderColor(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xff5A00A3), Color(0xffA30055)],
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.19,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xff111017),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.redo_outlined,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Undo',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: undoRedoStack.value._canRedo,
                    builder: (_, canRedo, __) {
                      return GestureDetector(
                          onTap:
                              canRedo ? () => undoRedoStack.value.redo() : null,
                          child: GradientBorderColor(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff5A00A3), Color(0xffA30055)],
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.19,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xff111017),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.redo_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Redo',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () => undoRedoStack.value.clear(),
                      child: GradientBorderColor(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xff5A00A3), Color(0xffA30055)],
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.19,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xff111017),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_copy,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Clear',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.12,
                  ),
                  GestureDetector(
                      onTap: () {
                        // Uint8List? pngBytes = await getBytes();
                        // if (pngBytes != null)

                        saveFile();
                        CherryToast.info(
                          disableToastAnimation: true,
                          title: const Text(
                            'Download SuccessFull !',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 12),
                          ),
                          action: const Text(
                            'This image has been downloaded to your phone image gallery',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          actionHandler: () {},
                          onToastClosed: () {
                            print('Toast closed');
                          },
                        ).show(context);
                      },
                      child: GradientBorderColor(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xff5A00A3), Color(0xffA30055)],
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff5A00A3), Color(0xffA30055)],
                            ),
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Download',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                  // TextButton(
                  //   onPressed: () async {
                  //     if (backgroundImage.value != null) {
                  //       backgroundImage.value = null;
                  //     } else {
                  //       backgroundImage.value = await _getImage;
                  //     }
                  //   },
                  //   child: Text(
                  //     backgroundImage.value == null
                  //         ? 'Add Background'
                  //         : 'Remove Background',
                  //   ),
                  // ),
                ],
              ),
            )),
        Container(
          width: MediaQuery.of(context).size.width * 0.16,
          height: MediaQuery.of(context).size.height * 0.868,
          decoration: BoxDecoration(
            color: const Color(0xff111017),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 3,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView(
              padding: const EdgeInsets.only(left: 3.0, right: 5.0),
              controller: scrollController,
              children: [
                const SizedBox(height: 10),
                _IconBox(
                  iconData: FontAwesomeIcons.pencil,
                  selected: drawingMode.value == DrawingMode.pencil,
                  onTap: () => drawingMode.value = DrawingMode.pencil,
                  tooltip: 'Pencil',
                ),
                const SizedBox(height: 10),
                _IconBox(
                  iconData: FontAwesomeIcons.eraser,
                  selected: drawingMode.value == DrawingMode.eraser,
                  onTap: () => drawingMode.value = DrawingMode.eraser,
                  tooltip: 'Eraser',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Stroke Type :',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Divider(),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _IconBox(
                      selected: drawingMode.value == DrawingMode.line,
                      onTap: () => drawingMode.value = DrawingMode.line,
                      tooltip: 'Line',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 2,
                            color: drawingMode.value == DrawingMode.line
                                ? Colors.grey.shade300
                                : Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    _IconBox(
                      iconData: Icons.hexagon_outlined,
                      selected: drawingMode.value == DrawingMode.polygon,
                      onTap: () => drawingMode.value = DrawingMode.polygon,
                      tooltip: 'Polygon',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.square,
                      selected: drawingMode.value == DrawingMode.square,
                      onTap: () => drawingMode.value = DrawingMode.square,
                      tooltip: 'Square',
                    ),
                    _IconBox(
                      iconData: FontAwesomeIcons.circle,
                      selected: drawingMode.value == DrawingMode.circle,
                      onTap: () => drawingMode.value = DrawingMode.circle,
                      tooltip: 'Circle',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    const Text(
                      'Fill Shape: ',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Checkbox(
                      value: filled.value,
                      checkColor: Colors.white,
                      activeColor: Colors.purple,
                      side: const BorderSide(color: Colors.white),
                      focusColor: Colors.white,
                      onChanged: (val) {
                        filled.value = val ?? false;
                      },
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: drawingMode.value == DrawingMode.polygon
                      ? Column(
                          children: [
                            const Text(
                              'Polygon Sides: ',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            RotatedBox(
                              quarterTurns:
                                  -1, // Rotate the slider 90 degrees anti-clockwise
                              child: Slider(
                                value: polygonSides.value.toDouble(),
                                inactiveColor: Colors.white,
                                min: 3,
                                max: 8,
                                activeColor: Color(0xff9572FB),
                                onChanged: (val) {
                                  polygonSides.value = val.toInt();
                                },
                                label: '${polygonSides.value}',
                                divisions: 5,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Colors',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ColorPalette(
                  selectedColor: selectedColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Size :(${strokeSize.value.toInt()})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),

                RotatedBox(
                  quarterTurns:
                      -1, // Rotate the slider 90 degrees anti-clockwise
                  child: Slider(
                    value: strokeSize.value,
                    inactiveColor: Colors.white,
                    min: 0,
                    max: 20,
                    activeColor: const Color(0xff9572FB),
                    onChanged: (val) {
                      strokeSize.value = val;
                    },
                  ),
                ),
                // Column(
                //   children: [
                //     const Text(
                //       'Eraser Size: ',
                //       style: TextStyle(fontSize: 12),
                //     ),
                //     RotatedBox(
                //       quarterTurns:
                //           -1, // Rotate the slider 90 degrees anti-clockwise
                //       child: Slider(
                //         value: eraserSize.value,
                //         min: 0,
                //         max: 80,
                //         onChanged: (val) {
                //           eraserSize.value = val;
                //         },
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // void saveFile(Uint8List bytes, String extension) async {
  //   await FileSaver.instance.saveFile(
  //     name: 'Painting-${DateTime.now().toIso8601String()}.$extension',
  //     bytes: bytes,
  //     ext: extension,
  //     mimeType: extension == 'jpeg' ? MimeType.png : MimeType.jpeg,
  //   );
  // }
  saveFile() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());

      print(result);
    }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (file != null) {
        final filePath = file.files.single.path;
        final bytes = filePath == null
            ? file.files.first.bytes
            : File(filePath).readAsBytesSync();
        if (bytes != null) {
          completer.complete(decodeImageFromList(bytes));
        } else {
          completer.completeError('No image selected');
        }
      }
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        completer.complete(
          decodeImageFromList(bytes),
        );
      } else {
        completer.completeError('No image selected');
      }
    }

    return completer.future;
  }

  // Future<Uint8List?> getBytes() async {
  //   RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
  //       ?.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage();
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List? pngBytes = byteData?.buffer.asUint8List();
  //   print("hoga $pngBytes");
  //   return pngBytes;
  // }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: const Color(0xff292839),
            border: Border.all(
              color: selected ? const Color(0xff8C65FF) : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey.shade300 : Colors.grey.shade300,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}

///A data structure for undoing and redoing sketches.
class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
