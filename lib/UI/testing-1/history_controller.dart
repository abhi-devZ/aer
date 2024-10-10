import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryController {
  List<String> history = [];
  String lastUrl = 'https://www.google.com';

  HistoryController._();

  static Future<HistoryController> initialize() async {
    final controller = HistoryController._();
    await controller._loadHistory();
    return controller;
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    lastUrl = prefs.getString('last_url') ?? lastUrl;
    history = prefs.getStringList('history') ?? [];
  }

  Future<void> addToHistory(String url) async {
    if (!history.contains(url)) {
      history.add(url);
      if (history.length > 100) {
        history.removeAt(0);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_url', url);
    await prefs.setStringList('history', history);
  }

  void showHistoryDialog(BuildContext context, Function(String) onUrlSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Browsing History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final url = history[history.length - 1 - index];
                return ListTile(
                  title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    onUrlSelected(url);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}