import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hsluv/hsluvcolor.dart';

class ColorOutput extends StatefulWidget {
  @override
  _ColorOutputState createState() => _ColorOutputState();
}

class _ColorOutputState extends State<ColorOutput> {
  int currentSegment;

  final Map<int, Widget> children = const <int, Widget>{
    0: Text("HEX"),
    1: Text("RGB"),
    2: Text("HSLuv"),
    3: Text("HSV"),
  };

  @override
  void initState() {
    currentSegment = PageStorage.of(context).readState(
          context,
          identifier: const ValueKey("Selectable"),
        ) ??
        0;

    super.initState();
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));

    Scaffold.of(context).hideCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text('$text copied'),
      duration: const Duration(milliseconds: 1000),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final background = Theme.of(context).colorScheme.background;

    final lum = HSLuvColor.fromColor(background).lightness;

    final arr = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.background,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CupertinoSlidingSegmentedControl<int>(
            children: children,
            backgroundColor:
                Theme.of(context).colorScheme.onBackground.withOpacity(0.20),
            thumbColor: surface,
            onValueChanged: onValueChanged,
            groupValue: currentSegment,
          ),
          SizedBox(height: 8),
          for (int i = 0; i < arr.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  primary: arr[i],
                  padding: EdgeInsets.all(16.0),
                  side: BorderSide(color: arr[i], width: 2),
                ),
                child: Text(
                  arr[i].retrieveColorStr(currentSegment),
                  style: TextStyle(
                    color: lum > 50 ? Colors.black : Colors.white,
                  ),
                ),
                onPressed: () {
                  copyToClipboard(
                    context,
                    arr[i].retrieveColorStr(currentSegment),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void onValueChanged(int newValue) {
    setState(() {
      currentSegment = newValue;
      PageStorage.of(context).writeState(
        context,
        currentSegment,
        identifier: const ValueKey("Selectable"),
      );
    });
  }
}

extension on Color {
  String retrieveColorStr(int kind) {
    switch (kind) {
      case 0:
        return "#${value.toRadixString(16).substring(2)}";
      case 1:
        return "R:$red G:$green B:$blue";
      case 2:
        final hsluv = HSLuvColor.fromColor(this);
        return "H:${hsluv.hue.round()} S:${hsluv.saturation.round()} L:${hsluv.lightness.round()}";
      case 3:
        final hsv = HSVColor.fromColor(this);
        return "H:${hsv.hue.round()} S:${(hsv.saturation * 100).round()} V:${(hsv.value * 100).round()}";
      default:
        return "error!";
    }
  }
}
