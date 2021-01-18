import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cache_data.dart';
import '../configuration.dart';
import '../flutter_custom_calendar.dart';
import '../utils/date_util.dart';

/// 月视图，显示整个月的日子
class MonthView extends StatefulWidget {
  final int year;
  final int month;
  final int day;

  final CalendarConfiguration configuration;

  const MonthView({
    Key key,
    @required this.year,
    @required this.month,
    this.day,
    this.configuration,
  }) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView>
    with AutomaticKeepAliveClientMixin {
  List<DateModel> _items = List(42);

  int lineCount;
  Map<DateModel, dynamic> extraDataMap; //自定义额外的数据

  @override
  void initState() {
    super.initState();
    extraDataMap = widget.configuration.extraDataMap;
    var firstDayOfMonth =
        DateModel.fromDateTime(DateTime(widget.year, widget.month, 1));
    if (CacheData.getInstance().monthListCache[firstDayOfMonth]?.isNotEmpty ==
        true) {
      _items = CacheData.getInstance().monthListCache[firstDayOfMonth];
    } else {
      getItems().then((_) {
        CacheData.getInstance().monthListCache[firstDayOfMonth] = _items;
      });
    }

    lineCount = DateUtil.getMonthViewLineCount(
        widget.year, widget.month, widget.configuration.offset);

    //第一帧后,添加监听，generation发生变化后，需要刷新整个日历
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<CalendarProvider>(context, listen: false)
          .generation
          .addListener(() async {
        extraDataMap = widget.configuration.extraDataMap;
        await getItems();
      });
    });
  }

  Future getItems() async {
    _items = await compute(initCalendarForMonthView, {
      'year': widget.year,
      'month': widget.month,
      'minSelectDate': widget.configuration.minSelectDate,
      'maxSelectDate': widget.configuration.maxSelectDate,
      'offset': widget.configuration.offset
    });
    setState(() {});
  }

  static Future<List<DateModel>> initCalendarForMonthView(
      Map<String, dynamic> map) async {
    return DateUtil.initCalendarForMonthView(
      map['year'] as int,
      map['month'] as int,
      DateTime.now(),
      DateTime.sunday,
      minSelectDate: map['minSelectDate'] as DateModel,
      maxSelectDate: map['maxSelectDate'] as DateModel,
      extraDataMap: map['extraDataMap'] as Map<DateModel, dynamic>,
      offset: map['offset'] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var calendarProvider =
        Provider.of<CalendarProvider>(context, listen: false);
    var configuration = calendarProvider.calendarConfiguration;

    return GridView.builder(
        addAutomaticKeepAlives: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: configuration.verticalSpacing,
        ),
        itemCount: _items.isEmpty ? 0 : _items.length,
        itemBuilder: (context, index) {
          var dateModel = _items[index];
          //判断是否被选择
          switch (configuration.selectMode) {

            /// 多选
            case CalendarSelectedMode.multiSelect:
              if (calendarProvider.selectedDateList.contains(dateModel)) {
                dateModel.isSelected = true;
              } else {
                dateModel.isSelected = false;
              }
              break;

            /// 选择开始和结束 中间的自动选择
            case CalendarSelectedMode.multiStartToEndSelect:
              if (calendarProvider.selectedDateList.contains(dateModel)) {
                dateModel.isSelected = true;
              } else {
                dateModel.isSelected = false;
              }
              break;

            /// 单选
            case CalendarSelectedMode.singleSelect:
              if (calendarProvider.selectDateModel == dateModel) {
                dateModel.isSelected = true;
              } else {
                dateModel.isSelected = false;
              }
              break;
          }
          dateModel.isCanClick =
              configuration.itemCanClick?.call(dateModel) ?? true;
          //这里使用objectKey，保证可以刷新。原因1：跟flutter的刷新机制有关。
          // 原因2：statefulElement持有state。
          return ItemContainer(
            dateModel: dateModel,
            key: ObjectKey(dateModel),
            clickCall: () {
              setState(() {});
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

/// 多选模式，包装item，这样的话，就只需要刷新当前点击的item就行了，不需要刷新整个页面

class ItemContainer extends StatefulWidget {
  final DateModel dateModel;

  final GestureTapCallback clickCall;

  const ItemContainer({Key key, this.dateModel, this.clickCall})
      : super(key: key);

  @override
  ItemContainerState createState() => ItemContainerState();
}

class ItemContainerState extends State<ItemContainer> {
  DateModel dateModel;
  CalendarConfiguration configuration;
  CalendarProvider calendarProvider;

  ValueNotifier<bool> isSelected;

  @override
  void initState() {
    super.initState();
    dateModel = widget.dateModel;
    isSelected = ValueNotifier(dateModel.isSelected);
  }

  /// 提供方法给外部，可以调用这个方法进行刷新item
  // ignore: avoid_positional_boolean_parameters
  void refreshItem(bool v) {
    /**
        Exception caught by gesture
        The following assertion was thrown while handling a gesture:
        setState() called after dispose()
     */
    v ??= false;
    if (mounted) {
      setState(() {
        dateModel.isSelected = v;
      });

      if (widget.clickCall != null) {
        widget.clickCall();
      }
    }
  }

  void notifyCationUnCalendarSelect(DateModel element) {
    if (configuration.unCalendarSelect != null) {
      configuration.unCalendarSelect(element);
    }
  }

  void notifyCationCalendarSelect(DateModel element) {
    if (configuration.calendarSelect != null) {
      configuration.calendarSelect(element);
    }
  }

  void updateWidget() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
//    LogUtil.log(TAG: this.runtimeType, message: "ItemContainerState build");
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    configuration = calendarProvider.calendarConfiguration;

    return GestureDetector(
      //点击整个item都会触发事件
      behavior: HitTestBehavior.opaque,
      onTap: () {
        //todo //范围外不可点击
        // if (!dateModel.isInRange) {
        //   return;
        // }
        if (dateModel.isCanClick) {
          configuration.onItemClick.call(
            this,
            configuration,
            dateModel,
            calendarProvider,
          );
        }
      },
      child: configuration.dayWidgetBuilder(dateModel),
    );
  }
}
