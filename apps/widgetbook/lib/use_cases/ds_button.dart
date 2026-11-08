import 'package:flutter/material.dart';
import 'package:wakeup_desktop/ds/ds_button.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';
import 'package:widgetbook/widgetbook.dart';

/// Component `Button` trong file Figma sandbox.
const dsButtonFigma = 'https://www.figma.com/design/zWidv5HFfFRIR9IrrFFObb';

/// Chỉnh từng tham số. Knob trùng tên tham số của DsButtonBase.
Widget dsButtonPlayground(BuildContext context) {
  final knobs = context.knobs;
  return DsButton(
    label: knobs.string(label: 'label', initialValue: 'Lưu'),
    variant: knobs.object.segmented(
      label: 'variant',
      options: DsButtonVariant.values,
      labelBuilder: (v) => v.figmaValue,
    ),
    size: knobs.object.segmented(
      label: 'size',
      options: DsButtonSize.values,
      labelBuilder: (v) => v.figmaValue,
    ),
    disabled: knobs.boolean(label: 'disabled'),
    onPressed: () {},
  );
}

/// Bảng mọi tổ hợp variant × size × disabled. Golden test chụp bảng này.
class DsButtonGallery extends StatelessWidget {
  const DsButtonGallery({super.key});

  /// Chuỗi kiểm tra dấu tiếng Việt chồng hai tầng (DS-13).
  static const vietnameseStress = 'Ếch ỗng Ữ Ặ';

  @override
  Widget build(BuildContext context) {
    final caption = TextStyle(
      fontFamily: DsFont.family,
      package: DsFont.package,
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in DsButtonVariant.values)
            for (final size in DsButtonSize.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        '${variant.figmaValue} · ${size.figmaValue}',
                        style: caption,
                      ),
                    ),
                    DsButton(
                      label: 'Lưu',
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    DsButton(
                      label: vietnameseStress,
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    DsButton(
                      label: 'Vô hiệu',
                      variant: variant,
                      size: size,
                      disabled: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
