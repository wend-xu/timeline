// import 'dart:collection';
//
// import 'package:timeline/cn/wendx/model/timeline.dart';
// import 'package:timeline/cn/wendx/repo/timeline_reporitory.dart';
//
// class MockTimeLineRepository implements TimelineRepository {
//   late Map<DateTime, String> _map;
//
//
//   MockTimeLineRepository(){
//     _map = {
//       // DateTime.now(): 'three',
//       DateTime.parse("2023-06-02 11:57:22"): '红毛来了1,该死',
//       DateTime.parse("2023-06-02 11:58:22"): '红毛走了2，真棒',
//       DateTime.parse("2023-06-02 11:59:22"): '红毛来了3，又来了好烦',
//       DateTime.parse("2023-06-02 12:57:22"): '红毛走了4，快走',
//       DateTime.parse("2023-06-02 13:57:22"): '红毛来了5，啊这，乜卵啊',
//       DateTime.parse("2023-06-02 14:57:22"): '红毛走了6，啊啊啊啊',
//     };
//     _map = SplayTreeMap.from(_map);
//   }
//
//
//
//   @override
//   Future<void> write(String line,DateTime dateTime) {
//     return Future.delayed(Duration(seconds: 5),(){
//       _map[dateTime] = line;
//     });
//   }
//
//   @override
//   Future<TimelineResp> readOneDay(TimelineLimitOneDay limit) async {
//     return TimelineResp(limit,_map);
//   }
//
//   @override
//   Future<DateTime> firstRecordDateTime() {
//     // TODO: implement firstRecordDateTime
//     throw UnimplementedError();
//   }
//
// }
