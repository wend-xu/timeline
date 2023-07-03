import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:timeline/cn/wendx/component/refresh_list_view_no_cache.dart';
import 'package:timeline/cn/wendx/model/timeline.dart';
import 'package:timeline/cn/wendx/repo/timeline_reporitory.dart';
import 'package:timeline/cn/wendx/util/date_utils.dart';

class TimelineSearchPage extends StatefulWidget {
  TimelineSearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TimelineSearchState();
  }
}

class TimelineSearchState extends State<TimelineSearchPage> {
  late final TimelineRepository _repositpry;

  final TextEditingController _content = TextEditingController();
  final TextEditingController _pickDateRange = TextEditingController();
  List<DateTime?> _pickDate = [];

  bool _init = false;

  int _total = 1;

  late ValueNotifier<TimelineLimitSearch> valueNotifier;

  @override
  void initState() {
    _repositpry= GetIt.instance.get<TimelineRepository>();
    var search = getSearch();
    valueNotifier = ValueNotifier(search);
    _repositpry.count(search).then((value) {
      _total = value;
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
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [_searchArea(), Expanded(child: _contentArea())],
      ),
    );
  }

  Widget _searchArea() {
    return Card(
        margin: const EdgeInsets.all(15),
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.content_paste_search,
                              ),
                              labelText: "搜索内容",
                            ),
                            controller: _content,
                          ),
                        )),
                    Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          child: TextField(
                            decoration: const InputDecoration(
                                hintText: "点击选择时间",
                                icon: Icon(Icons.timer)),
                            controller: _pickDateRange,
                            onTap: () {
                              showCalendarDatePicker2Dialog(
                                context: context,
                                config:
                                CalendarDatePicker2WithActionButtonsConfig(
                                  calendarType: CalendarDatePicker2Type.range,
                                  okButton: const Text("选择"),
                                  cancelButton: const Text("取消"),
                                ),
                                dialogSize: const Size(325, 400),
                                value: [DateTime.now()],
                                borderRadius: BorderRadius.circular(15),
                              ).then((date) {
                                print(date.toString());
                                if (date == null) {
                                  return;
                                }
                                _pickDate = date;
                                _pickDateRange.text =
                                    _formatPickDate(_pickDate);
                              });
                            },
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          _pickDate = [];
                          _content.text = "";
                          _pickDateRange.text = "";
                          _repositpry.count(getSearch()).then((total) {
                            _total = total;
                            valueNotifier.value = getSearch();
                          });
                        },
                        icon: const Icon(Icons.lock_reset),
                        label: const Text("重置")),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton.icon(
                          onPressed: () {
                            // valueNotifier.value = getSearch();
                              _repositpry.count(getSearch()).then((total) {
                                _total = total;
                                valueNotifier.value = getSearch();
                              });
                            // loading(
                            //   context, () {
                            //   _repositpry.count(getSearch()).then((total) {
                            //     _total = total;
                            //     valueNotifier.value = getSearch();
                            //   });
                            // },
                            // );
                          },
                          icon: const Icon(Icons.search),
                          label: const Text("搜索")),
                    )
                  ],
                )
              ],
            )));
  }

  String _formatPickDate(List<DateTime?> pickDate) {
    String result = "";
    result = formatDate_yyyy_mm_dd(pickDate[0]);
    if (pickDate.length > 1) {
      result = "$result - ${formatDate_yyyy_mm_dd(pickDate[1])}";
    }
    return result;
  }

  Widget _contentArea() {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Row(children: [
        Expanded(

          /// how too trigger
            child: ValueListenableBuilder<TimelineLimitSearch>(
              valueListenable: valueNotifier,
              builder: (BuildContext context, TimelineLimitSearch search,
                  Widget? child) {
                return _buildListView();
              },
            ))
      ]),
    );
  }

  Widget _buildListView() {
    return RefreshListViewNoCache<NoteItem>(
      refresh: () async {},
      getTotal: () {
        return _total;
      },
      loadData: (index) async {
        var search = getSearch(
          // contentLike: this._content.text,
          // noteTimeRange: this._pickDate,
            limit: 1,
            offset: index);
        TimelineResp<TimelineLimitSearch> timelineResp =
        await _repositpry.read(search);
        return toLoadResp(timelineResp);
      },
      loadingData: () => NoteItem.loadStyle(),
      buildItem: (item, index) {
        return Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text("${item.noteTime.toString()}"),
                    Spacer(),
                    Text("#${index + 1}")
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(item.content),
              ),
              Divider(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("搜索"),
    );
  }

  LoadResp<NoteItem> toLoadResp(
      TimelineResp<TimelineLimitSearch> timelineResp) {
    var limit = timelineResp.limit;

    List<NoteItem> dataList = [];
    timelineResp.data.forEach((key, value) {
      dataList.add(NoteItem(key, value));
    });

    return LoadResp<NoteItem>(
        offset: limit.offset,
        limit: limit.limit,
        total: limit.total,
        dataList: dataList);
  }

  TimelineLimitSearch getSearch({int? limit, int? offset}) {
    // 如果选择了时间范围的上界，选择器插件时间为 00:00:00 将其日期 +1 变为第二日零点
    if(_pickDate.length == 2 && _pickDate[1] != null){
      var pickDateLe = _pickDate[1];
      pickDateLe!.add(const Duration(days: 1));
    }
    
    return TimelineLimitSearch.flex(
        contentLike: _content.text,
        noteTimeRange: _pickDate,
        total: _total,
        limit: limit,
        offset: offset
    );
  }
}

class NoteItem {
  DateTime noteTime;

  String content;

  NoteItem(this.noteTime, this.content);

  NoteItem.loadStyle()
      : noteTime = DateTime.fromMillisecondsSinceEpoch(0),
        content = "加载中";

  @override
  String toString() {
    return 'NoteItem{noteTime: $noteTime, content: $content}';
  }
}
