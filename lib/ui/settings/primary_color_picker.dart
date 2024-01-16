import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:statera/ui/color/seed_color_cubit.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class PrimaryColorPicker extends StatefulWidget {
  const PrimaryColorPicker({Key? key}) : super(key: key);

  @override
  State<PrimaryColorPicker> createState() => _PrimaryColorPickerState();
}

class _PrimaryColorPickerState extends State<PrimaryColorPicker> {
  late Color _newColor;

  SeedColorCubit get _seedColorCubit => context.read<SeedColorCubit>();

  @override
  void initState() {
    _newColor = _seedColorCubit.state;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Theme Color'),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _newColor,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pick a color'),
            content: ColorPicker(
              pickerColor: _newColor,
              onColorChanged: (color) {
                setState(() => _newColor = color);
              },
            ),
            actions: [
              CancelButton(),
              FilledButton(
                onPressed: () {
                  _seedColorCubit.setColor(_newColor);
                  Navigator.pop(context);
                },
                child: Text('Set'),
              )
            ],
          ),
        );
      },
    );
  }
}
