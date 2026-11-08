import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

/// Nút của design system, component Figma `Button` (ADR-0008).
///
/// Tên tham số, kiểu và giá trị mặc định đến từ [DsButtonBase] sinh từ
/// `components.json`; widget chỉ thêm hành vi ([onPressed], focus).
///
/// Kích thước, padding, bo góc, cỡ chữ lấy đúng theo `Button` trong Figma.
/// Figma chưa vẽ hover / pressed / focus / disabled nên các trạng thái này
/// đang theo giả định ở [_DsButtonStyle], chờ designer vẽ.
class DsButton extends DsButtonBase {
  const DsButton({
    super.key,
    required super.label,
    required this.onPressed,
    super.disabled,
    super.size,
    super.variant,
    this.focusNode,
    this.autofocus = false,
  });

  /// Gọi khi bấm chuột hoặc nhấn Enter / Space lúc đang focus. `null` thì nút
  /// bị vô hiệu như khi [disabled] là `true`.
  final VoidCallback? onPressed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// Nút bấm được: không [disabled] và có [onPressed].
  bool get enabled => !disabled && onPressed != null;

  @override
  Widget build(BuildContext context) => _DsButtonView(button: this);
}

/// Thông số theo `Button` trong Figma (file sandbox, đọc ngày 08/11/2026).
/// Figma chưa có Variables số cho khoảng cách / bo góc / chữ nên chưa sinh
/// được token; thay bằng token khi có.
abstract final class _DsButtonSpec {
  static const radius = 8.0;
  static const fontWeight = FontWeight.w500;

  /// Figma để line height AUTO = (ascender + descender) của Inter
  /// = (1984 + 494) / 2048. Đặt rõ để không kế thừa height của
  /// DefaultTextStyle (Material 3 bodyMedium là 1,43).
  static const lineHeight = 2478 / 2048;

  static EdgeInsets padding(DsButtonSize size) => switch (size) {
    DsButtonSize.md => const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    DsButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  };

  static double fontSize(DsButtonSize size) => switch (size) {
    DsButtonSize.md => 16,
    DsButtonSize.sm => 14,
  };
}

/// Trạng thái chưa có trong Figma. Giá trị là giả định, chờ designer vẽ
/// `state=hover|pressed|focus|disabled` (DS-09).
abstract final class _DsButtonStyle {
  /// Lớp phủ màu chữ lên nền khi hover / nhấn.
  static const hoverOverlay = 0.08;
  static const pressedOverlay = 0.12;

  /// Độ mờ cả nút khi vô hiệu.
  static const disabledOpacity = 0.4;

  /// Viền focus: dày 2, cách nút 2 (DS-08: viền focus luôn hiện, ≥ 3:1).
  static const focusRingWidth = 2.0;
  static const focusRingGap = 2.0;
}

class _DsButtonView extends StatefulWidget {
  const _DsButtonView({required this.button});

  final DsButton button;

  @override
  State<_DsButtonView> createState() => _DsButtonViewState();
}

class _DsButtonViewState extends State<_DsButtonView> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  DsButton get _b => widget.button;

  void _activate() {
    if (_b.enabled) _b.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<DsColors>()!;
    final (background, foreground) = switch (_b.variant) {
      DsButtonVariant.primary => (colors.bgPrimary, colors.textOnPrimary),
      DsButtonVariant.secondary => (colors.bgSecondary, colors.textOnSecondary),
    };
    final enabled = _b.enabled;
    final overlay = !enabled
        ? 0.0
        : _pressed
        ? _DsButtonStyle.pressedOverlay
        : _hovered
        ? _DsButtonStyle.hoverOverlay
        : 0.0;
    final fill = Color.alphaBlend(
      foreground.withValues(alpha: overlay),
      background,
    );

    Widget body = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(_DsButtonSpec.radius),
      ),
      child: Padding(
        padding: _DsButtonSpec.padding(_b.size),
        child: Text(
          _b.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: DsFont.family,
            package: DsFont.package,
            fontSize: _DsButtonSpec.fontSize(_b.size),
            fontWeight: _DsButtonSpec.fontWeight,
            height: _DsButtonSpec.lineHeight,
            color: foreground,
          ),
        ),
      ),
    );

    if (_focused && enabled) {
      const outset =
          _DsButtonStyle.focusRingGap + _DsButtonStyle.focusRingWidth;
      body = Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          Positioned(
            left: -outset,
            top: -outset,
            right: -outset,
            bottom: -outset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.bgPrimary,
                    width: _DsButtonStyle.focusRingWidth,
                  ),
                  borderRadius: BorderRadius.circular(
                    _DsButtonSpec.radius + outset,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!enabled) {
      body = Opacity(opacity: _DsButtonStyle.disabledOpacity, child: body);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: _b.focusNode,
        autofocus: _b.autofocus,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _activate(),
          ),
        },
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTap: enabled ? _activate : null,
          child: body,
        ),
      ),
    );
  }
}
