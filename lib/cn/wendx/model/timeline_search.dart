import 'package:timeline/cn/wendx/model/timeline.dart';

abstract class TimelineLimit {}

class TimelineLimitOneDay implements TimelineLimit {
  DateTime date;

  TimelineLimitOneDay({DateTime? pickDate}) : date = pickDate ?? DateTime.now();
}

class TimelineLimitSearch implements TimelineLimit {
  DateTime? noteTimeLe;
  DateTime? noteTimeGe;
  String? contentLike;

  int offset;
  int limit;
  int total;

  bool isAsc;

  TimelineLimitSearch(
      {this.noteTimeLe,
      this.noteTimeGe,
      this.contentLike,
      offset,
      limit,
      total,
      isAsc})
      : offset = offset ?? 0,
        limit = limit ?? 20,
        total = total ?? 0,
        isAsc = isAsc ??false;

  TimelineLimitSearch.flex(
      {this.contentLike, List<DateTime?>? noteTimeRange, offset, limit, total, isAsc})
      : noteTimeLe =
            (noteTimeRange?.length ?? 0) > 0 ? noteTimeRange![0] : null,
        noteTimeGe =
            (noteTimeRange?.length ?? 0) > 1 ? noteTimeRange![1] : null,
        offset = offset ?? 0,
        limit = limit ?? 20,
        total = total ?? 0,
        isAsc = isAsc ?? true;

  bool isEmpty() {
    return noteTimeLe == null && noteTimeGe == null && contentLike == null;
  }
}

class TimelineResp<T extends TimelineLimit> {
  T limit;

  // Map<DateTime,Timeline> data;
  List<Timeline> data;

  bool resultEmpty;

  String msg = "";

  TimelineResp(this.limit, this.data, {String? message})
      : resultEmpty = data.isEmpty,
        msg = message ?? "";

  TimelineResp.emptyR(this.limit, {String? message})
      : resultEmpty = true,
        data = [],
        msg = message ?? "";
}
