import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hondana/features/reader/presentation/widgets/reader_image.dart';

void main() {
  late Directory directory;
  late List<String> pages;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('reader-images-');
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 20, 40),
      Paint()..color = Colors.white,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(20, 40);
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    pages = [];
    for (var i = 0; i < 901; i++) {
      final file = File('${directory.path}/$i.png');
      await file.writeAsBytes(bytes);
      pages.add(file.path);
    }
  });

  tearDownAll(() => directory.delete(recursive: true));

  testWidgets('retains first page geometry after visiting 901 local images', (
    tester,
  ) async {
    final ratios = <String, double>{};
    for (final page in pages) {
      await tester.pumpWidget(_Harness(url: page, ratios: ratios));
      for (var attempt = 0; attempt < 100 && ratios[page] == null; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
        await tester.pump();
      }
      expect(ratios[page], 0.5);
    }
    expect(ratios.length, 901);
    await tester.pumpWidget(const SizedBox.shrink());
    PaintingBinding.instance.imageCache.clear();
    await tester.pumpWidget(_Harness(url: pages.first, ratios: ratios));
    // The first frame already reserves the correct height before redecoding.
    expect(
      tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
      0.5,
    );
    expect(tester.widget<Image>(find.byType(Image)).image, isA<ResizeImage>());
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('paged mode retains original resolution for pinch zoom', (
    tester,
  ) async {
    await tester.pumpWidget(_Harness(url: pages.first));
    expect(tester.widget<Image>(find.byType(Image)).image, isA<FileImage>());
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.url, this.ratios});

  final String url;
  final Map<String, double>? ratios;

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(360, 800),
    builder: (context, child) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ReaderImage(
            url: url,
            reserveHeight: ratios != null,
            aspectRatios: ratios,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    ),
  );
}
