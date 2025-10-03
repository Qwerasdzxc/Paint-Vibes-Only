import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:painter/shared/models/color_palette.dart';
import 'dart:math' as math;

/// Enhanced color picker widget with HSV support and palette management
class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final ColorPalette? palette;
  final Function(ColorPalette)? onPaletteUpdated;
  final bool showHsvPicker;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.palette,
    this.onPaletteUpdated,
    this.showHsvPicker = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current color display and picker button
          Row(
            children: [
              GestureDetector(
                onTap: () => _showColorPickerDialog(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Selected Color',
                  style: TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Predefined colors
          if (palette != null) ...[
            _buildColorSection('Predefined Colors', palette!.predefinedColors),
            const SizedBox(height: 8),
          ],

          // Custom colors
          if (palette != null && palette!.customColors.isNotEmpty) ...[
            _buildColorSection('Custom Colors', palette!.customColors),
            const SizedBox(height: 8),
          ],

          // Recent colors
          if (palette != null && palette!.recentColors.isNotEmpty) ...[
            _buildColorSection('Recent Colors', palette!.recentColors),
          ],
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<Color> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: colors.map((color) {
            final isSelected = color.value == selectedColor.value;
            return GestureDetector(
              onTap: () {
                onColorSelected(color);
                if (palette != null && onPaletteUpdated != null) {
                  final updatedPalette = palette!.addToRecentColors(color);
                  onPaletteUpdated!(updatedPalette);
                }
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: isSelected ? Colors.black : Colors.grey[400]!, width: isSelected ? 3 : 1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Option to switch between pickers
                ToggleButtons(
                  isSelected: [!showHsvPicker, showHsvPicker],
                  onPressed: (index) {
                    Navigator.of(context).pop();
                    _showColorPickerDialog(context);
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Basic')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('HSV')),
                  ],
                ),
                const SizedBox(height: 16),

                // Show appropriate picker
                showHsvPicker
                    ? HSVColorPicker(
                        initialColor: selectedColor,
                        onColorChanged: (color) {
                          tempColor = color;
                        },
                      )
                    : BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          tempColor = color;
                        },
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                onColorSelected(tempColor);
                if (palette != null && onPaletteUpdated != null) {
                  final updatedPalette = palette!.addCustomColor(tempColor).addToRecentColors(tempColor);
                  onPaletteUpdated!(updatedPalette);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
}

/// Custom HSV color picker widget
class HSVColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final double width;
  final double height;

  const HSVColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.width = 280,
    this.height = 320,
  });

  @override
  State<HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<HSVColorPicker> {
  late HSVColor _currentHsv;

  @override
  void initState() {
    super.initState();
    _currentHsv = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColor(HSVColor hsv) {
    setState(() {
      _currentHsv = hsv;
    });
    widget.onColorChanged(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(
        children: [
          // HSV Wheel
          Expanded(flex: 2, child: _buildHSVWheel()),
          const SizedBox(height: 16),

          // Sliders
          _buildHueSlider(),
          const SizedBox(height: 8),
          _buildSaturationSlider(),
          const SizedBox(height: 8),
          _buildValueSlider(),
          const SizedBox(height: 16),

          // Color preview and hex
          _buildColorPreview(),
        ],
      ),
    );
  }

  Widget _buildHSVWheel() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        onPanDown: (details) => _updateFromWheelPosition(details.localPosition),
        onPanUpdate: (details) => _updateFromWheelPosition(details.localPosition),
        child: CustomPaint(painter: HSVWheelPainter(_currentHsv), size: Size.infinite),
      ),
    );
  }

  void _updateFromWheelPosition(Offset position) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final center = Offset(box.size.width / 2, box.size.width / 2);
    final radius = math.min(center.dx, center.dy);

    final offset = position - center;
    final distance = offset.distance;

    if (distance <= radius) {
      final angle = (math.atan2(offset.dy, offset.dx) + math.pi * 2) % (math.pi * 2);
      final hue = (angle / (math.pi * 2)) * 360;
      final saturation = (distance / radius).clamp(0.0, 1.0);

      _updateColor(_currentHsv.withHue(hue).withSaturation(saturation));
    }
  }

  Widget _buildHueSlider() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
        ),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 20,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          thumbColor: Colors.white,
          overlayColor: Colors.white.withAlpha(32),
        ),
        child: Slider(
          value: _currentHsv.hue / 360,
          onChanged: (value) {
            _updateColor(_currentHsv.withHue(value * 360));
          },
        ),
      ),
    );
  }

  Widget _buildSaturationSlider() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [_currentHsv.withSaturation(0).toColor(), _currentHsv.withSaturation(1).toColor()],
        ),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 20,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          thumbColor: Colors.white,
          overlayColor: Colors.white.withAlpha(32),
        ),
        child: Slider(
          value: _currentHsv.saturation,
          onChanged: (value) {
            _updateColor(_currentHsv.withSaturation(value));
          },
        ),
      ),
    );
  }

  Widget _buildValueSlider() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [Colors.black, _currentHsv.withValue(1).toColor()]),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 20,
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          thumbColor: Colors.white,
          overlayColor: Colors.white.withAlpha(32),
        ),
        child: Slider(
          value: _currentHsv.value,
          onChanged: (value) {
            _updateColor(_currentHsv.withValue(value));
          },
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    final color = _currentHsv.toColor();
    final hex = color.value.toRadixString(16).substring(2).toUpperCase();

    return Row(
      children: [
        Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('#$hex', style: const TextStyle(fontFamily: 'monospace')),
        ),
      ],
    );
  }
}

/// Custom painter for HSV color wheel
class HSVWheelPainter extends CustomPainter {
  final HSVColor hsv;

  HSVWheelPainter(this.hsv);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(center.dx, center.dy) - 2;

    // Draw hue wheel
    const steps = 360;
    for (int i = 0; i < steps; i++) {
      final angle = (i / steps) * 2 * math.pi;
      final hue = (i / steps) * 360;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, HSVColor.fromAHSV(1, hue, 1, 1).toColor()],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), angle - 0.01, 0.02, true, paint);
    }

    // Draw selection indicator
    final selectedAngle = (hsv.hue / 360) * 2 * math.pi;
    final selectedRadius = hsv.saturation * radius;
    final indicatorPos = Offset(
      center.dx + selectedRadius * math.cos(selectedAngle),
      center.dy + selectedRadius * math.sin(selectedAngle),
    );

    canvas.drawCircle(
      indicatorPos,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      indicatorPos,
      4,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(HSVWheelPainter oldDelegate) {
    return oldDelegate.hsv != hsv;
  }
}
