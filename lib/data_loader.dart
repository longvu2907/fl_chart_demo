import 'dart:async';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:stock_chart/models/stock_index.dart';

Future<List<StockIndex>> loadStockData() async {
  final String fileData = await rootBundle.loadString('assets/data.csv');
  var res = const CsvToListConverter().convert(fileData, eol: "\n");

  List<StockIndex> data = [];
  for (var i = 1; i < res.length; i++) {
    data.add(
      StockIndex(
        date: DateFormat('d/M/y').parse(res[i][0]),
        close: res[i][1],
        open: res[i][2],
        high: res[i][3],
        low: res[i][4],
        volume: res[i][5],
        adjustedClose: res[i][6],
      ),
    );
  }

  return data;
}
