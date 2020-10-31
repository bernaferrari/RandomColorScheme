import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:random_color_scheme/random_color_scheme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'preview/chat_preview.dart';
import 'preview/social_preview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Color Scheme',
      home: RefreshableHome(),
    );
  }
}

class RefreshableHome extends StatefulWidget {
  @override
  _RefreshableHomeState createState() => _RefreshableHomeState();
}

class _RefreshableHomeState extends State<RefreshableHome> {
  int refreshSeed = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeList(refreshSeed),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Random Color Scheme",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FeatherIcons.github,
              color: Colors.black,
            ),
            tooltip: "GitHub",
            onPressed: () async {
              await launch("https://github.com/bernaferrari/RandomColorScheme");
            },
          )
        ],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            refreshSeed += 25;
          });
        },
        label: Text("Refresh"),
        icon: Icon(Icons.refresh),
        backgroundColor: Colors.red[500],
      ),
    );
  }
}

class ThemeList extends StatelessWidget {
  final int refresh;

  ThemeList(this.refresh);

  Theme customTheme({Widget child, int i, bool isDark}) {
    return Theme(
      data: ThemeData(
        colorScheme: randomColorScheme(seed: i + refresh, isDark: isDark),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      child: ThemeItem(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final condition = MediaQuery.of(context).size.width > 950;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListView(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: Color(0xff00ba7c)),
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                """
This is the sample for a library.
The idea is for you to plug randomColorScheme() into your apps and discover new material themes.""",
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          for (int i = 0; i < 25; i++)
            Flex(
              direction: condition ? Axis.horizontal : Axis.vertical,
              children: [
                Flexible(
                  flex: condition ? 1 : 0,
                  child: customTheme(
                    child: ThemeItem(),
                    i: i,
                    isDark: true,
                  ),
                ),
                Flexible(
                  flex: condition ? 1 : 0,
                  child: customTheme(
                    child: ThemeItem(),
                    i: i,
                    isDark: false,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class ThemeItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 0,
      child: Row(
        children: [
          Expanded(child: SocialPreview()),
          Expanded(child: ChatPreview()),
        ],
      ),
    );
  }
}
