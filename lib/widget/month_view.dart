import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/cache_data.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:provider/provider.dart';

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
  List<DateModel> items = List();

  int lineCount;
  Map<DateModel, dynamic> extraDataMap; //自定义额外的数据

  @override
  void initState() {
    super.initState();
    extraDataMap = widget.configuration.extraDataMap;
    DateModel firstDayOfMonth =
        DateModel.fromDateTime(DateTime(widget.year, widget.month, 1));
    if (CacheData.getInstance().monthListCache[firstDayOfMonth]?.isNotEmpty ==
        true) {
      LogUtil.log(TAG: this.runtimeType, message: "缓存中有数据");
      items = CacheData.getInstance().monthListCache[firstDayOfMonth];
    } else {
      LogUtil.log(TAG: this.runtimeType, message: "缓存中无数据");
      getItems().then((_) {
        CacheData.getInstance().monthListCache[firstDayOfMonth] = items;
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
    items = await compute(initCalendarForMonthView, {
      'year': widget.year,
      'month': widget.month,
      'minSelectDate': widget.configuration.minSelectDate,
      'maxSelectDate': widget.configuration.maxSelectDate,
      'offset': widget.configuration.offset
    });
    setState(() {});
  }

  static Future<List<DateModel>> initCalendarForMonthView(Map map) async {
    return DateUtil.initCalendarForMonthView(
        map['year'], map['month'], DateTime.now(), DateTime.sunday,
        minSelectDate: map['minSelectDate'],
        maxSelectDate: map['maxSelectDate'],
        extraDataMap: map['extraDataMap'],
        offset: map['offset']);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LogUtil.log(TAG: this.runtimeType, message: "_MonthViewState build");

    CalendarProvider calendarProvider =
        Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;

    return new GridView.builder(
        addAutomaticKeepAlives: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: configuration.verticalSpacing,
        ),
        itemCount: items.isEmpty ? 0 : items.length,
        itemBuilder: (context, index) {
          DateModel dateModel = items[index];
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
            case CalendarSelectedMode.mutltiStartToEndSelect:
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

          return ItemContainer(
            dateModel: dateModel,
            key: ObjectKey(dateModel),
            clickCall: () {
              setState(() {});

              /// 如果是选择开始和结束则进行刷新日历
            },
            //这里使用objectKey，保证可以刷新。原因1：跟flutter的刷新机制有关。原因2：statefulElement持有state。
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

  void notifiCationUnCalendarSelect(DateModel element) {
    if (configuration.unCalendarSelect != null) {
      configuration.unCalendarSelect(element);
    }
  }

  void notifiCationCalendarSelect(DateModel element) {
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
      onTap: () => configuration.onItemClick.call(
        this,
        configuration,
        dateModel,
        calendarProvider,
      ),
      child: configuration.dayWidgetBuilder(dateModel),
    );
  }
}
