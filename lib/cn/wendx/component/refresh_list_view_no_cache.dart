import 'package:flutter/material.dart';

typedef BuildItem<T> = Widget Function(T t, int index);

typedef LoadData<T> = Future<LoadResp<T>> Function(int index);

typedef GetTotal = int Function();

typedef LoadingData<T> = T Function();

class LoadResp<T> {
  int offset;

  int limit;

  int total;

  bool hasMore;

  List<T> dataList;

  LoadResp({
    required this.offset,
    required this.limit,
    required this.total,
    required this.dataList,
  }) : hasMore = offset + limit < total;
}

enum WrapperStatus { loading, normal }

class RefreshWrapper<T> {
  WrapperStatus wrapperStatus;

  T value;

  RefreshWrapper(this.wrapperStatus, this.value);

  RefreshWrapper.load(this.value) : wrapperStatus = WrapperStatus.loading;

  RefreshWrapper.normal(this.value) : wrapperStatus = WrapperStatus.normal;
}

class RefreshListViewNoCache<T> extends StatelessWidget {
  RefreshCallback _refresh;

  LoadData<T> _loadData;

  LoadingData<T> _loadingData;

  BuildItem<T> _buildItem;

  GetTotal _getTotal;

  final ScrollController _scrollController = ScrollController();

  /// 缓存的数目不等于 cacheData的 length
  /// 当list实际存储的对象超过 _maxCacheCount 时需要丢弃调部分数据释放内存

  RefreshListViewNoCache(
      {required RefreshCallback refresh,
      required LoadData<T> loadData,
      required LoadingData<T> loadingData,
      required BuildItem<T> buildItem,
      required GetTotal getTotal,
      super.key,
      int? firstLoadSize,
      int? pullSize,
      int? maxCacheCount})
      : _refresh = refresh,
        _loadData = loadData,
        _loadingData = loadingData,
        _buildItem = buildItem,
        _getTotal = getTotal;

  @override
  Widget build(BuildContext context) {

    ListView listView = ListView.builder(
        itemCount: _getTotal(),
        controller: _scrollController,
        itemBuilder: (context, index) {
          ValueNotifier<RefreshWrapper<T>> wrapper =
              _createLoadingValueNotify();
          _loadData(index).then((resp) {
            var dataList = resp.dataList;
            if (dataList.isNotEmpty) {
              wrapper.value = RefreshWrapper.normal(dataList[0]);
            }
          });
          return ValueListenableBuilder<RefreshWrapper<T>>(
              valueListenable: wrapper,
              builder: (BuildContext context, RefreshWrapper<T> wrapper,
                  Widget? child) {
                return _buildItem(wrapper.value, index);
              });
          //return _buildItem(cacheData!, index);
        });

    return RefreshIndicator(child: listView, onRefresh: _refresh);
  }

  ValueNotifier<RefreshWrapper<T>> _createLoadingValueNotify() {
    return ValueNotifier(RefreshWrapper.load(_loadingData()));
  }
}
