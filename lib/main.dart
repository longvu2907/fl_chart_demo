import 'package:flutter/material.dart';
import 'package:stock_chart/bar_chart.dart';
import 'package:stock_chart/line_chart.dart';
import 'package:stock_chart/pie_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(title: 'VNINDEX'),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StockLineChart(),
            SizedBox(height: 20),
            Text(
              'Số lượng CP tăng, giảm, không đổi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            StockPieChart(),
            SizedBox(height: 20),
            StockBarChart(),
          ],
        ),
      ),
    );
  }
}
