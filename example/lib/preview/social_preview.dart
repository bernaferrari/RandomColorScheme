import 'package:flutter/material.dart';

import '../color_output.dart';

class SocialPreview extends StatelessWidget {
  const SocialPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            height: 1,
          ),
          ListTile(
            title: const Text(
              "Trending",
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text(
              "Design updates",
              overflow: TextOverflow.ellipsis,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.account_balance,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.share_outlined),
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
                        titlePadding: const EdgeInsets.only(left: 16, top: 16),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xff080808)
                                : Colors.white,
                        contentPadding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NotButton("Primary", Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
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
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              Icons.border_inner,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
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
