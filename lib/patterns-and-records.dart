import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DocumentScreen(document: Document()),
    );
  }
}

const documentJson = '''
{
  "metadata": {
    "title": "My Document",
    "modified": "2024-02-04"
  },
  "blocks": [
    {
      "type": "h1",
      "text": "Chapter 1"
    },
    {
      "type": "p",
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    },
    {
      "type": "checkbox",
      "checked": true,
      "text": "Learn Dart 3"
    }
  ]
}

''';

class Document {
  final Map<String, Object?> _json;
  Document() : _json = jsonDecode(documentJson);

  (String, {DateTime modified}) get metadata {
    if (_json
        case {
          'metadata': {'title': String title, 'modified': String localModified}
        }) {
      return (title, modified: DateTime.parse(localModified));
    } else {
      throw const FormatException("Unexpected Json");
    }
  }

  List<Block> getBlocks() {
    if (_json case {'blocks': List blockList}) {
      return [for (final block in blockList) Block.fromjson(block)];
    } else {
      throw const FormatException("Unexpected JSON");
    }
  }
}

class HeaderBlock extends Block {
  final String text;
  HeaderBlock(this.text);
}

class ParagraphBlock extends Block {
  final String text;
  ParagraphBlock(this.text);
}

class CheckboxBlock extends Block {
  final String text;
  final bool checked;
  CheckboxBlock(this.text, this.checked);
}

// Enums in Dart
sealed class Block {
  Block();

  factory Block.fromjson(Map<String, dynamic> json) {
    return switch (json) {
      {"type": "h1", "text": String text} => HeaderBlock(text),
      {"type": "p", "text": String text} => ParagraphBlock(text),
      {"type": "checkbox", "text": String text, "checked": bool checked} =>
        CheckboxBlock(text, checked),
      _ => throw const FormatException("Unexpected JSON"),
    };
  }
}

String formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = dateTime.difference(now);
  return switch (difference) {
    Duration(inDays: 0) => "today",
    Duration(inDays: 1) => "tomorrow",
    Duration(inDays: -1) => "yesterday",
    Duration(inDays: final days) when days >= 7 =>
      "${days ~/ 7} weeks from now",
    Duration(inDays: final days) when days <= -7 => "${days ~/ 7} weeks ago",
    Duration(inDays: final days, isNegative: true) => "$days days ago",
    Duration(inDays: final days) => "$days days later",
  };
}

class DocumentScreen extends StatelessWidget {
  final Document document;
  const DocumentScreen({required this.document, super.key});

  @override
  Widget build(BuildContext context) {
    final (title, :modified) = document.metadata;
    final blocks = document.getBlocks();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Center(
            child: Text('Last modified ${formatDate(modified)}'),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: blocks.length,
                  itemBuilder: (context, index) {
                    return BlockWidget(block: blocks[index]);
                  }))
        ],
      ),
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;
  const BlockWidget({required this.block, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        child: switch (block) {
          HeaderBlock(:final text) => Text(
              text,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ParagraphBlock(:final text) => Text(text),
          CheckboxBlock(:final text, :final checked) => Row(
              children: [
                Checkbox(value: checked, onChanged: (_) {}),
                Text(text)
              ],
            )
        });
  }
}
