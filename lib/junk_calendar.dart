library flutter_calendar;

import 'package:flutter/material.dart';
import 'package:dart_date/dart_date.dart';

pprint(dynamic data) {
  print(data);
}

DateTime _getDateFromMonthsSinceEpoch(int monthsSinceEpoch) {
  var month = DateTime(1970, 1, 1).addMonths(monthsSinceEpoch);
  pprint('month: $monthsSinceEpoch date: $month');
  return month;
}

int _getMonthSinceEpoch(DateTime date) {
  return (((date.year) - 1970) * 12) + date.month - 1;
}

class JunkCalendarController {
  DateTime initialDate;

  var pageController = PageController(
    initialPage: _getMonthSinceEpoch(DateTime.now()).toInt(),
  );

  Future<bool?> nextMonth({bool animate = true, Duration? duration, Cubic? curve}) {
    return goToDate((_myDate ?? initialDate).startOfMonth.nextMonth, animate: animate, duration: duration, curve: curve);
  }

  Future<bool?> previousMonth({
    bool animate = true,
    Duration? duration,
    Cubic? curve,
  }) {
    return goToDate(
      (_myDate ?? initialDate).startOfMonth.previousMonth,
      animate: animate,
      duration: duration,
      curve: curve,
    );
  }

  Future<bool?> goToDate(
    DateTime date, {
    bool animate = true,
    Duration? duration,
    Cubic? curve,
  }) async {
    try {
      var getMonthSinceEpoch = _getMonthSinceEpoch(date);
      _myDate = date;
      // pprint(_getDateFromMonthsSinceEpoch(getMonthSinceEpoch));
      if (!animate) {
        pageController.jumpToPage(
          getMonthSinceEpoch,
        );
        return true;
      }
      await pageController.animateToPage(
        getMonthSinceEpoch,
        duration: duration ?? const Duration(seconds: 5),
        curve: curve ?? Curves.easeInOut,
      );
      return true;
    } catch (e) {
      throw Exception(
        '''Error going to date: $e. This should be fixed by the developers. 
           Create an issue at''',
      );
    }
  }

  DateTime? get currentDate {
    return pageController.page?.toInt() != null ? _getDateFromMonthsSinceEpoch(pageController.page!.toInt()) : null;
  }

  String get asdf {
    var d = _getDateFromMonthsSinceEpoch(1);
    var monthNUmber = _getMonthSinceEpoch(d);
    pprint({
      'monthNumber': monthNUmber,
      'date': d,
    });
    return '';
  }

  DateTime? _myDate;

  JunkCalendarController({required this.initialDate}) {
    _myDate = initialDate;
  }
}

var days = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];
var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

extension PrettyFormatting on DateTime {
  String toPretthyString() {
    return '${months[month - 1]}-$year';
  }
}

class JunkCalendar extends StatefulWidget {
  const JunkCalendar({
    super.key,
    this.controller,
    this.border,
    this.cellBuilder,
    this.headerCellBuilder,
    this.initialDate,
    this.titleBarBuilder,
    this.scrollDirection = Axis.vertical
  });

  final JunkCalendarController? controller;
  final TableBorder? border;
  final Widget Function(DateTime date, bool isCurrentMonth)? cellBuilder;
  final Widget Function(DateTime date)? titleBarBuilder;
  final Widget Function(String day)? headerCellBuilder;
  final DateTime? initialDate;
  final Axis scrollDirection;

  @override
  State<JunkCalendar> createState() {
    return _JunkCalendarState();
  }
}

class _JunkCalendarState extends State<JunkCalendar> {
  late JunkCalendarController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        JunkCalendarController(
          initialDate: widget.initialDate ?? DateTime.now(),
        );
    controller.pageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  int getMonthSinceEpoch(DateTime date) {
    var i = (((date.year) - 1970) * 12) + date.month;
    return i;
  }

  Future<bool> goToDate(DateTime date) async {
    setState(() {
      controller.initialDate = date;
    });
    await controller.pageController.animateToPage(
      getMonthSinceEpoch(date),
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: widget.controller?.pageController,
        scrollDirection: widget.scrollDirection,
        itemBuilder: (context, index) {
          return Container(
            child: _SingleMonthView(
              titleBarBuilder: widget.titleBarBuilder,
              cellBuilder: widget.cellBuilder,
              border: widget.border,
              date: _getDateFromMonthsSinceEpoch(index),
              headerCellBuilder: widget.headerCellBuilder,
            ),
          );
        });
  }
}

class CalendarCell extends StatelessWidget {
  const CalendarCell({super.key, required this.date, required this.targetMonth});

  final DateTime date;
  final DateTime targetMonth;

  @override
  Widget build(BuildContext context) {
    var isSameMonth = date.month == targetMonth.month;
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        date.day.toString(),
        style: TextStyle(color: isSameMonth ? Colors.white : Colors.grey),
      ),
    );
  }
}

class _SingleMonthView extends StatelessWidget {
  const _SingleMonthView({
    super.key,
    required this.date,
    this.border,
    this.cellBuilder,
    this.headerCellBuilder, this.titleBarBuilder,
  });
  final DateTime date;

  final TableBorder? border;
  final Widget Function(DateTime date, bool isCurrentMonth)? cellBuilder;
  final Widget Function(String day)? headerCellBuilder;
  final Widget Function(DateTime date)? titleBarBuilder;

  @override
  Widget build(BuildContext context) {
    var d = date;

    var week = d.startOfMonth.weekday;
    var firstDayToDisplay = (d.startOfMonth.subDays((d.startOfMonth.weekday == 7 ? 0 : d.startOfMonth.weekday)));

    List<List<DateTime?>> arrays = [];

    for (var i = 0; i < 6; i++) {
      var arrayForWeek = <DateTime?>[];
      for (var j = 0; j < 7; j++) {
        arrayForWeek.add(DateTime(
          firstDayToDisplay.year,
          firstDayToDisplay.month,
          firstDayToDisplay.day + ((i * 7) + j).toInt(),
        ));
      }
      arrays.add(arrayForWeek);
    }
    var daysRow = days
        .map((e) => headerCellBuilder != null
            ? headerCellBuilder!(e)
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(e),
              ))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBarBuilder != null
            ? titleBarBuilder!(date)
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date.toPretthyString(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
        Table(
          border: border ?? TableBorder.all(width: 0),
          children: [
            TableRow(children: daysRow),
            ...arrays.map(
              (e) => TableRow(
                children: e
                    .map((e) => cellBuilder != null
                        ? cellBuilder!(e!, e.month == date.month)
                        : CalendarCell(
                            date: e!,
                            targetMonth: date,
                          ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
