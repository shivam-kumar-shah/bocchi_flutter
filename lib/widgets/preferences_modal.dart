import 'package:anime_api/providers/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesModal extends StatelessWidget {
  const PreferencesModal({super.key});

  void callback(
    BuildContext context,
    String quality,
  ) async {
    await Provider.of<Watchlist>(
      context,
      listen: false,
    ).setQuality(quality: quality);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Watchlist>(
      builder: (context, value, child) {
        final data = value.preferredQuality;
        final prefferedTitle = value.prefferedTitle.name;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 20,
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Video quality preferences",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Flex(
                direction: Axis.horizontal,
                children: [
                  _buildButton(
                    "360p",
                    () => callback(context, "360"),
                    data == "360",
                    context,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildButton(
                    "720p",
                    () => callback(context, "720"),
                    data == "720",
                    context,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildButton(
                    "1080p",
                    () => callback(context, "1080"),
                    data == "1080",
                    context,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Title preference",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 20,
              ),
              Flex(
                direction: Axis.horizontal,
                children: [
                  _buildButton(
                    "English",
                    () {
                      value.setTitle(title: PrefferedTitle.english);
                    },
                    prefferedTitle == "english",
                    context,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  _buildButton(
                    "Romaji",
                    () {
                      value.setTitle(title: PrefferedTitle.romaji);
                    },
                    prefferedTitle == "romaji",
                    context,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Flexible _buildButton(
    String value,
    VoidCallback callback,
    bool active,
    BuildContext context,
  ) {
    return Flexible(
      child: ElevatedButton(
        onPressed: callback,
        style: !active
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.white,
                ),
              )
            : null,
        child: Text(value),
      ),
    );
  }
}
