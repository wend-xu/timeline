import 'package:date_picker_timeline_fixed/date_picker_timeline_fixed.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/page/comp/content_area_comp.dart';
import 'package:timeline/cn/wendx/page/comp/input_area_comp.dart';
import 'package:timeline/cn/wendx/repo/timeline_reporitory.dart';
import 'package:timeline/cn/wendx/route/name_route_manager.dart';


class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TimelineState();
  }
}

class TimelineState extends State<TimelinePage> {
  static const String notFirstRecordTitle = "暂时还乜有想法 Σ( ° △ °|||)︴";

  late TimelineRepository _repository;

  late OrderInfo _noteInfo;

  bool _init = false;

  bool _displayTimeline = true;

  late DateTime _pickDate;
  final DatePickerController _datePickerController = DatePickerController();
  late DateTime _minDate;

  @override
  void initState() {
    super.initState();
    // asyncInit();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading(tip: "准备打开数据库");
      _repository = await GetIt.instance.get<TimelineRepository>();
      _noteInfo = await _readDate(TimelineLimitOneDay());
      _minDate = await _repository.firstRecordDateTime();

      print("异步初始化完成");
      endLoading();
      setState(() {
        _init = true;
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    if (!_init) {
      return Material(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(), // 加载指示器
            SizedBox(height: 10),
            Text("稍等下下，我在打开数据库"),
          ],
        ),
      ));
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _datePickerController.animateToSelection();
    });

    List<Widget> content = [];
    if (_displayTimeline) {
      content.add(Expanded(
        child: _buildTopTimeLine(),
        flex: 1,
      ));
    }

    content.add(Expanded(
      child: ContentAreaComp(_noteInfo, listen: changeOrderInfo),
      flex: 6,
    ));
    content.add(Expanded(
      child: InputAreaComp(listen: addOrderInfo),
      flex: 1,
    ));

    return Scaffold(
        appBar: _appBar(),
        body: Column(
          children: content,
        ));
  }

  AppBar _appBar2() {
    return AppBar(
      title: Center(
        child: Text("bobo 时间线"),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      actions: [
        ElevatedButton.icon(
          icon: Icon(Icons.search),
          label: Text("搜索"),
          onPressed: () {
            Navigator.pushNamed(context, R.timelineSearch);
          },
        ),
        PopupMenuButton(
          icon: Icon(Icons.location_on),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _displayTimeline = !_displayTimeline;
                    });
                  },
                  icon: Icon(_displayTimeline
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode),
                  label: Text(_displayTimeline ? "隐藏时间线" : "展示时间线")),
              value: 1,
            ),
            PopupMenuItem(
              child: TextButton.icon(
                  onPressed: () {
                    DateTime now = DateTime.now();
                    _datePickerController.setDateAndAnimate(now);
                    _readDateAndRefresh(now);
                  },
                  icon: Icon(Icons.today),
                  label: Text("定位并选择今天")),
              value: 1,
            ),
            PopupMenuItem(
              child: TextButton.icon(
                  onPressed: () {
                    _datePickerController.animateToDate(DateTime.now());
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text("定位到今天")),
              value: 1,
            ),
            PopupMenuItem(
              child: TextButton.icon(
                  onPressed: () {
                    _datePickerController.animateToSelection();
                  },
                  icon: Icon(Icons.check_box),
                  label: Text("定位到已选")),
              value: 1,
            ),
          ],
          onSelected: (value) {
            // do something
          },
        )
      ],
    );
  }

  void changeOrderInfo() {
    loading(tip: "刷新数据中");
    _readDate(TimelineLimitOneDay(pickDate: _pickDate)).then((orderInfo) {
      setState(() {
        _noteInfo = orderInfo;
      });
      endLoading();
    });
  }

  void addOrderInfo(String content, DateTime dateTime) {
    loading(tip: "biu~biubiu～\n发射中～～～");
    _repository.write(content, dateTime).then((value) {
      var now = DateTime.now();
      if (_getTime(_pickDate) != _getTime(now)) {
        /// setDateAndAnimate 不会触发dateChange的会调，需要再这里手动刷新下数据
        _datePickerController.setDateAndAnimate(now);
        _readDateAndRefresh(now);
      }
      OrderInfo noteInfo = _noteInfo;
      var deliveryProcesses = noteInfo.deliveryProcesses;

      /// 无论何时添加记录，只要上午的 title 为 [notFirstRecordTitle] 就刷新上午的记录
      var am = deliveryProcesses[0];
      if (am.name == notFirstRecordTitle) {
        am = DeliveryProcess("上午");
        deliveryProcesses[0] = am;
      }

      if (isAm(dateTime)) {
        deliveryProcesses[0]
            .messages
            .add(DeliveryMessage(dateTime, _getTime(dateTime), content));
      } else {
        var deliveryProcesse = deliveryProcesses[1];
        if (deliveryProcesse.isCompleted) {
          DeliveryProcess pm = DeliveryProcess("下午");
          pm.messages
              .add(DeliveryMessage(dateTime, _getTime(dateTime), content));
          deliveryProcesses[1] = pm;
          deliveryProcesses.add(deliveryProcesse);
        } else {
          deliveryProcesse.messages
              .add(DeliveryMessage(dateTime, _getTime(dateTime), content));
        }
      }

      setState(() {
        _noteInfo = noteInfo;
      });
    }).whenComplete(() => endLoading());
  }

  Future<OrderInfo> _readDate(TimelineLimitOneDay limit) async {
    var data = await _repository.readOneDay(limit);
    return _convertToOrderInfo(data);
  }

  Future<void> _readDateAndRefresh(DateTime pickDate) {
    loading();
    return Future(() async {
      OrderInfo orderInfo =
          await _readDate(TimelineLimitOneDay(pickDate: pickDate));
      setState(() {
        _noteInfo = orderInfo;
        _pickDate = pickDate;
        endLoading();
      });
    });
  }

  OrderInfo _convertToOrderInfo(TimelineResp<TimelineLimitOneDay> resp) {
    var driverInfo = const DriverInfo(name: "", thumbnailUrl: "");

    DeliveryProcess am = DeliveryProcess("上午");
    DeliveryProcess pm = DeliveryProcess("下午");

    if (resp.data.isEmpty) {
      am = DeliveryProcess(notFirstRecordTitle);
    } else {
      resp.data.forEach((time, content) {
        if (isAm(time)) {
          am.messages.add(DeliveryMessage(time, _getTime(time), content));
        } else {
          pm.messages.add(DeliveryMessage(time, _getTime(time), content));
        }
      });
    }

    var deliveryProcesses = [am];
    if (pm.messages.isNotEmpty) {
      deliveryProcesses.add(pm);
    }
    deliveryProcesses
        .add(DeliveryProcess.complete("biu biu biu 更多想法 (๑•̀ㅂ•́)و✧"));
    return OrderInfo(
        id: 1,
        date: resp.limit.date,
        driverInfo: driverInfo,
        deliveryProcesses: deliveryProcesses);
  }

  bool isAm(DateTime time) {
    return time.hour < 12;
  }

  String _getTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future loading({String? tip, BuildContext? contextO}) {
    return showDialog(
      context: contextO ?? context,
      barrierDismissible: false, // 是否允许用户点击对话框外部关闭
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // 加载指示器
                SizedBox(height: 10),
                Text(tip ?? 'biu~biubiu～\n加载中～～～'),
              ],
            ),
          ),
        );
      },
    );
  }

  void endLoading({BuildContext? contextO}) {
    Navigator.of(contextO ?? context).pop();
  }

  Widget _buildTopTimeLine({DateTime? initDate}) {
    initDate ??= DateTime.now();
    _pickDate = initDate;

    var datePicker = DatePicker(
      _minDate,
      initialSelectedDate: _pickDate,
      selectionColor: Colors.black,
      selectedTextColor: Colors.white,
      onDateChange: (date) {
        _pickDate = date;
        _readDateAndRefresh(_pickDate);
      },
      controller: _datePickerController,
    );

    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    double dy = event.scrollDelta.dy;
                    double length = dy.abs();
                    if (length < 10) {
                      return;
                    }
                    // > 0 向右， < 0 向左
                    bool flag = dy > 0;
                    //todo 需要给时间设定范围，如果大于或小于边界值直接设定为边界值
                    int moveDay = length > 300
                        ? 10
                        : (length < 30 ? 1 : (length / 30).floor());
                    _pickDate = flag
                        ? _pickDate.add(Duration(days: moveDay))
                        : _pickDate.subtract(Duration(days: moveDay));
                    if (_pickDate.isBefore(_minDate)) {
                      _pickDate = _minDate;
                    }
                    _datePickerController.animateToDate(_pickDate);
                  }
                },
                child: datePicker),
          ],
        ));
  }
}
