import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:recase/recase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'CSV to Dart-Variable Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void csvConvert() async {
    final input = await rootBundle.loadString('assets/translations/langs.csv');

    final List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(input);
    String dartCode = "";
    for (var element in rowsAsListOfValues) {
      final String variableName = ReCase(element[0]).camelCase;
      if (element[1].contains("{}")) {
        final paramCount = (element[1] as String).split("{}").length - 1;
        final List<String> paramDeclaration = [];
        final List<String> params = [];
        for (var i = 0; i < paramCount; i++) {
          final paramName = "param$i";
          paramDeclaration.add("String $paramName");
          params.add(paramName);
        }
        dartCode +=
            "\nstatic String $variableName(${paramDeclaration.join(",")}) { return \"${element[0]}\".tr(args: [${params.join(",")}]); } \n";
      } else {
        dartCode +=
            "static final String $variableName = \"${element[0]}\".tr(); \n";
      }
    }
    log(dartCode);
  }

  @override
  void initState() {
    super.initState();
    csvConvert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text(
          'Place your csv file in assets/translations/lang.csv \n\n Build this project \n\n And look over to your debug console',
        ),
      ),
    );
  }
}
