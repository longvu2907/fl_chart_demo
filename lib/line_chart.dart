import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_chart/data_loader.dart';
import 'package:stock_chart/models/stock_index.dart';

class StockLineChart extends StatefulWidget {
  const StockLineChart({super.key});

  @override
  State<StockLineChart> createState() => _StockLineChartState();
}

class _StockLineChartState extends State<StockLineChart> {
  final int _divider = 100;

  List<StockIndex> data = const [];
  List<FlSpot> chartData = const [];
  String rangeView = "1M";
  late StockIndex currentData;

  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _prepareStockData();
  }

  void _prepareStockData() async {
    data = await loadStockData();
    currentData = data[0];

    updateChartData();
  }

  void updateChartData() {
    double minY = double.maxFinite;
    double maxY = double.minPositive;

    var end = 30;
    switch (rangeView) {
      case "1M":
        end = 30;
        break;
      case "3M":
        end = 90;
        break;
      case "1Y":
        end = 365;
        break;
      case "5Y":
        end = 365 * 5;
        break;
      default:
        end = 30;
    }

    chartData =
        data.getRange(0, end > data.length ? data.length : end).map((data) {
      if (minY > data.close) minY = data.close;
      if (maxY < data.close) maxY = data.close;
      return FlSpot(
        data.date.millisecondsSinceEpoch.toDouble(),
        data.close,
      );
    }).toList();

    _minX = chartData.last.x;
    _maxX = chartData.first.x;
    _minY = (minY / _divider).floorToDouble() * _divider;
    _maxY = (maxY / _divider).ceilToDouble() * _divider;

    setState(() {});
  }

  double percent = 1;

  LineChartData _mainData() {
    return LineChartData(
      gridData: _gridData(),
      titlesData: FlTitlesData(
        bottomTitles: _bottomTitles(),
        leftTitles: _leftTitles(),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
      ),
      minX: _minX,
      maxX: _maxX,
      minY: _minY,
      maxY: _maxY,
      lineBarsData: [_lineBarData()],
      lineTouchData: _lineTouchData(),
    );
  }

  LineTouchData _lineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final flSpot = barSpot;
            if (flSpot.x == 0 || flSpot.x == 6) {
              return null;
            }

            return LineTooltipItem(
              '${DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt()),
              )} \n',
              const TextStyle(
                color: Colors.white70,
              ),
              children: [
                TextSpan(
                  text: flSpot.y.toString(),
                ),
              ],
            );
          }).toList();
        },
      ),
      getTouchedSpotIndicator:
          (LineChartBarData barData, List<int> indicators) {
        return indicators.map(
          (int index) {
            return const TouchedSpotIndicatorData(
              FlLine(
                color: Colors.grey,
                strokeWidth: 1,
                dashArray: [2, 4],
              ),
              FlDotData(show: true),
            );
          },
        ).toList();
      },
      touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
        if (event is FlTapUpEvent ||
            event is FlLongPressEnd ||
            lineTouch == null ||
            lineTouch.lineBarSpots == null) {
          setState(() {
            currentData = data[0];
          });

          return;
        }

        var index = lineTouch.lineBarSpots![0].spotIndex;

        setState(() {
          currentData = data[index];
        });
      },
    );
  }

  LineChartBarData _lineBarData() {
    return LineChartBarData(
      spots: chartData,
      color: const Color.fromARGB(255, 124, 189, 255),
      dotData: const FlDotData(show: false),
    );
  }

  AxisTitles _leftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => Text(
          value.toInt().toString(),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        reservedSize: 40,
      ),
    );
  }

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            margin: value == _maxX
                ? const EdgeInsets.only(right: 70)
                : const EdgeInsets.only(left: 70),
            child: Text(
              DateFormat('dd/MM/yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(value.toInt()),
              ),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        interval: _maxX,
      ),
    );
  }

  FlGridData _gridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Colors.black12,
          strokeWidth: 1,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 10,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                bottom: 5,
              ),
              child: Row(
                children: [
                  Wrap(
                    spacing: 6,
                    children: data.isNotEmpty
                        ? [
                            Row(
                              children: [
                                const Text("O ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                Text(
                                  currentData.open.toString(),
                                  style: TextStyle(
                                    color: currentData.adjustedClose > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("H ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                Text(
                                  currentData.high.toString(),
                                  style: TextStyle(
                                    color: currentData.adjustedClose > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("L ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                Text(
                                  currentData.low.toString(),
                                  style: TextStyle(
                                    color: currentData.adjustedClose > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("C ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                Text(
                                  currentData.close.toString(),
                                  style: TextStyle(
                                    color: currentData.adjustedClose > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Vol ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                Text(
                                  currentData.volume.toString(),
                                  style: TextStyle(
                                    color: currentData.adjustedClose > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ]
                        : [],
                  ),
                ],
              ),
            ),
            Expanded(
              child: chartData.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : LineChart(_mainData()),
            ),
            const SizedBox(
              height: 5,
            ),
            Wrap(
              spacing: 10,
              children: () {
                const arr = ["1M", "3M", "1Y", "5Y"];

                return arr
                    .map(
                      (e) => ElevatedButton(
                        onPressed: () {
                          setState(() {
                            rangeView = e;
                            updateChartData();
                          });
                        },
                        style: rangeView != e
                            ? const ButtonStyle(
                                foregroundColor: MaterialStatePropertyAll(
                                  Colors.black,
                                ),
                                backgroundColor: MaterialStatePropertyAll(
                                  Colors.white,
                                ),
                              )
                            : null,
                        child: Text(e),
                      ),
                    )
                    .toList();
              }(),
            ),
          ],
        ),
      ),
    );
  }
}
