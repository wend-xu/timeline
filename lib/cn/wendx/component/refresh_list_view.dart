import 'package:flutter/material.dart';

typedef BuildItem<T> = Widget Function(T t, int index);

typedef LoadData<T> = Future<LoadResp<T>> Function(int index, int length);

typedef LoadingData<T> = T Function();

class LoadResp<T> {
  int offset;

  int limit;

  int total;

  bool hasMore;

  List<T> dataList;

  LoadResp(
      {required this.offset,
      required this.limit,
      required this.total,
      required this.dataList})
      : hasMore = offset + limit < total;
}

enum WrapperStatus { loading, normal }

class RefreshWrapper<T> {
  WrapperStatus wrapperStatus;

  T value;

  RefreshWrapper(this.wrapperStatus, this.value);

  RefreshWrapper.load(this.value) : wrapperStatus = WrapperStatus.loading;

  RefreshWrapper.normal(this.value) : wrapperStatus = WrapperStatus.normal;
}

/// 继承 [StatefulWidget和StatelessWidget] 实现下拉加载和上拉刷新
/// 刷新、加载、item构建的方法都由外层传入
/// 理论上应该需要使用者提供一个方法用于实现
///
/// 下拉刷新是否可以理解为一种特殊的分页请求
/// RefreshListView 实现 ListView 的itemBuilder
///   根据index判断是否需要加载数据，如果需要加载，
///   在listView的末尾拼接一条加载中
///   等future执行完毕将最后一条移除，将数据渲染出来
///   根据future结果，判断是否有hasMore
///   如果没有hasMore，在list最后拼接一条没有更多
///   如果最后一条是没有更多，下拉一样执行加载中，可能在future会有数据
///
/// refresh： 给一个controller
///
/// 如果要支持从任意index开始的话，就会出现一个需要 合并的情况，直接用一个List来实现就可以
///
/// todo 清空缓存后续实现
/// todo 兼容无缓存模式
class RefreshListView<T> extends StatelessWidget {
  RefreshCallback _refresh;

  LoadData<T> _loadData;

  LoadingData<T> _loadingData;

  BuildItem<T> _buildItem;

  int _firstLoadSize;

  int _pullSize;

  final ScrollController _scrollController = ScrollController();

  final List<ValueNotifier<RefreshWrapper<T>>?> _cacheData = [];

  /// 缓存的数目不等于 cacheData的 length
  /// 当list实际存储的对象超过 _maxCacheCount 时需要丢弃调部分数据释放内存
  int _cacheCount = 0;
  int? _maxCacheCount;

  /// 数据总数
  int? _total;

  bool _loading = false;

  RefreshListView(
      {required RefreshCallback refresh,
      required LoadData<T> loadData,
      required LoadingData<T> loadingData,
      required BuildItem<T> buildItem,
      super.key,
      int? firstLoadSize,
      int? pullSize,
      int? maxCacheCount})
      : _firstLoadSize = firstLoadSize ?? 20,
        _pullSize = pullSize ?? 20,
        _maxCacheCount = maxCacheCount ?? 5000,
        _refresh = refresh,
        _loadData = loadData,
        _loadingData = loadingData,
        _buildItem = buildItem;

  @override
  Widget build(BuildContext context) {
    ListView listView = ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          ValueNotifier<RefreshWrapper<T>> wrapper;

          /// 触发下拉数据加载
          if ((index + 1) > _cacheData.length) {
            /// 需要加载的时候：
            ///   返回一个数据加载中的条目样式，禁用继续下拉
            ///   等数据加载完成，通过controller往上滑动一条，
            ///   之后向下滑动一条，是否可以
            ///
            ///
            _loadAndMergeToCache(index, _pullSize);

            /// 展示数据加载中的
            wrapper = _createLoadingValueNotify();
          } else {
            ValueNotifier<RefreshWrapper<T>>? data = _cacheData[index];

            /// .eg 下滑超过最大缓存长度，数据被丢弃，上滑时需要重新加载，
            ///   这时候弹出dialog， 等数据加载完成关闭dialog，触发rebuild
            ///   可以通过controller控制回拉到上一个item，实现类似阻塞的感觉，
            ///   等数据加载完了触发一个 滑动，或者等用户重新滑动
            ///
            /// todo 这种时候应该判断他的滑动范围时向上还是向下？
            ///
            if (data == null) {
              wrapper = _createLoadingValueNotify();
              _loadAndMergeToCache(index + 1 - _pullSize, _pullSize);
            } else {
              wrapper = data;
            }
          }

          _cacheData.insert(index, wrapper);

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

  /// 合并请求到的数据到缓存列表
  /// 更新缓存数目
  /// todo 这里目前会存在多线程问题
  /// 因为_cacheData的length不等于_cacheCount
  ///
  /// todo 判断滑动方向来清空数据
  void _loadAndMergeToCache(int index, int size) {
    // if(_loading){
    //   print("数据加载中，直接返回");
    //   return;
    // }
    print("开始加载数据");
    _loading = true;
    _loadData(index, size).then((loadResp) {
      print("触发数据加载");
      var dataList = loadResp.dataList;

      if (dataList.isEmpty) {
        return;
      }
      var offset = loadResp.offset;

      /// 实际返回的数据可能 <= 需要的数据量
      var limit = dataList.length;
      for (int step = 0; step < limit; step++) {
        int currentIndex = offset + step;
        T currentData = dataList[step];

        /// 如果index是越界的那直接插进去，如果index没有越界的情况下获取然后set
        if (_cacheData.length < currentIndex ||
            _cacheData[currentIndex] == null) {
          _cacheData.insert(
              currentIndex, ValueNotifier(RefreshWrapper.normal(currentData)));
        } else {
          var cacheData = _cacheData[currentIndex]!;
          cacheData.value = RefreshWrapper.normal(currentData);
        }
        //print("$currentIndex | ${currentData.toString()}");
      }
      _cacheCount + _cacheCount + offset;
      _total = loadResp.total;
      _loading = false;
    });
  }

  ValueNotifier<RefreshWrapper<T>> _createLoadingValueNotify() {
    return ValueNotifier(RefreshWrapper.load(_loadingData()));
  }
}
