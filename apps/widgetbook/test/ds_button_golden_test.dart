// Golden chỉ chạy trên Linux: CI (ubuntu) là nguồn chuẩn, render chữ khác
// nhau giữa hệ điều hành. Cập nhật: `flutter test --update-goldens` trên Linux.
@TestOn('linux')
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_desktop/ds/ds_button.dart';
import 'package:wakeup_desktop/ds/ds_theme.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';
import 'package:wakeup_widgetbook/use_cases/ds_button.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required ThemeData theme,
  Size size = const Size(560, 300),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

void main() {
  for (final (name, theme) in [
    ('light', DsTheme.light()),
    ('dark', DsTheme.dark()),
  ]) {
    testWidgets('bảng biến thể ($name)', (tester) async {
      await _pump(tester, const DsButtonGallery(), theme: theme);
      await expectLater(
        find.byType(DsButtonGallery),
        matchesGoldenFile('goldens/ds_button_gallery_$name.png'),
      );
    });
  }

  testWidgets('kích thước khớp Figma: md 91×39, sm 69×29', (tester) async {
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DsButton(label: 'Button', onPressed: () {}),
          DsButton(label: 'Button', size: DsButtonSize.sm, onPressed: () {}),
        ],
      ),
      theme: DsTheme.light(),
    );
    final md = tester.getSize(find.byType(DsButton).first);
    final sm = tester.getSize(find.byType(DsButton).last);
    expect(md.width, closeTo(91, 1));
    expect(md.height, closeTo(39, 1));
    expect(sm.width, closeTo(69, 1));
    expect(sm.height, closeTo(29, 1));
  });

  for (final variant in DsButtonVariant.values) {
    final v = variant.figmaValue;
    Widget button() => Padding(
      padding: const EdgeInsets.all(12),
      child: DsButton(label: 'Lưu', variant: variant, onPressed: () {}),
    );

    testWidgets('hover ($v)', (tester) async {
      await _pump(
        tester,
        button(),
        theme: DsTheme.light(),
        size: const Size(120, 64),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(DsButton)));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ds_button_${v}_hover.png'),
      );
    });

    testWidgets('pressed ($v)', (tester) async {
      await _pump(
        tester,
        button(),
        theme: DsTheme.light(),
        size: const Size(120, 64),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(DsButton)),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ds_button_${v}_pressed.png'),
      );
      await gesture.up();
    });

    testWidgets('focus bằng bàn phím ($v)', (tester) async {
      await _pump(
        tester,
        button(),
        theme: DsTheme.light(),
        size: const Size(120, 64),
      );
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ds_button_${v}_focus.png'),
      );
    });
  }
}
