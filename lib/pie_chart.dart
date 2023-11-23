import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stock_chart/app_color.dart';

class StockPieChart extends StatefulWidget {
  const StockPieChart({super.key});

  @override
  State<StockPieChart> createState() => _StockPieChartState();
}

class _StockPieChartState extends State<StockPieChart> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 110.0 : 100.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.contentColorGreen,
            value: (263 / 576) * 100,
            title: 'Tăng (263)',
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.contentColorRed,
            value: (93 / 576) * 100,
            title: 'Giảm (93)',
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: AppColors.contentColorYellow,
            value: (220 / 576) * 100,
            title: 'Không đổi (220)',
            radius: radius,
          );
        default:
          throw Exception('Oh no');
      }
    });
  }
}
