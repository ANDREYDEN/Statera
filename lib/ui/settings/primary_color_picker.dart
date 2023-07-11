import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:statera/ui/color/color_state.dart';
import 'package:statera/ui/widgets/buttons/cancel_button.dart';

class PrimaryColorPicker extends StatefulWidget {
  const PrimaryColorPicker({Key? key}) : super(key: key);

  @override
  State<PrimaryColorPicker> createState() => _PrimaryColorPickerState();
}

class _PrimaryColorPickerState extends State<PrimaryColorPicker> {
  late Color _newColor;

  @override
  void initState() {
    _newColor = context.read<ColorState>().color;
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
            content: SizedBox(
              width: 300,
              child: ColorPicker(
                pickerColor: _newColor,
                onColorChanged: (color) {
                  setState(() => _newColor = color);
                },
              ),
            ),
            actions: [
              CancelButton(),
              ElevatedButton(
                onPressed: () {
                  Provider.of<ColorState>(context, listen: false)
                      .setColor(_newColor);
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
