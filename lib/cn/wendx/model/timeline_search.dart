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

  TimelineLimitSearch(
      {this.noteTimeLe,
      this.noteTimeGe,
      this.contentLike,
      offset,
      limit,
      total})
      : offset = offset ?? 0,
        limit = limit ?? 20,
        total = total ?? 0;

  TimelineLimitSearch.flex(
      {this.contentLike, List<DateTime?>? noteTimeRange, offset, limit, total})
      : noteTimeLe =
            (noteTimeRange?.length ?? 0) > 0 ? noteTimeRange![0] : null,
        noteTimeGe =
            (noteTimeRange?.length ?? 0) > 1 ? noteTimeRange![1] : null,
        offset = offset ?? 0,
        limit = limit ?? 20,
        total = total ?? 0;

  bool isEmpty() {
    return noteTimeLe == null && noteTimeGe == null && contentLike == null;
  }
}

class TimelineResp<T extends TimelineLimit> {
  T limit;

  Map<DateTime, String> data;

  bool resultEmpty;

  String msg = "";

  TimelineResp(this.limit, this.data, {String? message})
      : resultEmpty = data.isEmpty,
        msg = message ?? "";

  TimelineResp.emptyR(this.limit, {String? message})
      : resultEmpty = true,
        data = {},
        msg = message ?? "";
}
