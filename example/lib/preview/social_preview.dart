import 'package:flutter/material.dart';

import '../color_output.dart';

class SocialPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              "What's happening",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
            height: 1.0,
          ),
          ListTile(
            title: Text("Trending", overflow: TextOverflow.ellipsis),
            subtitle: Text("Design updates", overflow: TextOverflow.ellipsis),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.account_balance,
                size: 24.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16.0),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: Icon(Icons.share_outlined),
                label: Text(
                  "Export",
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Export (click to copy)'),
                        titlePadding: EdgeInsets.only(left: 16.0, top: 16.0),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Color(0xff080808)
                                : Colors.white,
                        contentPadding: EdgeInsets.all(8.0),
                        children: <Widget>[
                          ColorOutput(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NotButton("Primary", Theme.of(context).colorScheme.primary),
                SizedBox(width: 8.0),
                _NotButton(
                  "Secondary",
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotButton extends StatelessWidget {
  final String text;
  final Color color;

  const _NotButton(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.border_inner,
              color: color,
              size: 16.0,
            ),
            SizedBox(width: 8.0),
            Text(
              text,
              style:
                  Theme.of(context).textTheme.bodyText2?.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
