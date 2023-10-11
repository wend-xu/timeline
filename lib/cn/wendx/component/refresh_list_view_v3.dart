import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(T t, int index);

typedef ItemLoader<T> = Future<LoadResp<T>> Function(int offset, int limit);

class LoadResp<T> {
  int offset;

  int limit;

  int total;

  bool hasMore;

  List<T> dataList;

  LoadResp({required this.offset,
    required this.limit,
    required this.total,
    required this.dataList})
      : hasMore = offset + limit < total;
}

/// EasyRefresh  提供的是触发 下拉加载 和 上滑刷新 的功能
/// 数据的加载和维护还是得自行处理
/// 不要用listView的builder方法，直接传入维护的数据
class RefreshListViewV3<T> extends StatefulWidget {
  final EasyRefreshController _controller;

  final int _pullSize;

  final int _initSize;

  final ItemBuilder<T> _itemBuilder;

  final ItemLoader<T> _itemLoader;

  RefreshListViewV3({
    EasyRefreshController? controller,
    int? pullSize,
    int? initSize,
    required ItemBuilder<T> itemBuilder,
    required ItemLoader<T> itemLoader,
  })
      : _controller = controller ?? EasyRefreshController(),
        _pullSize = pullSize ?? 20,
        _initSize = initSize ?? 20,
        _itemBuilder = itemBuilder,
        _itemLoader = itemLoader;

  @override
  State<StatefulWidget> createState() {
    return RefreshListViewV3State<T>();
  }
}

class RefreshListViewV3State<T> extends State<RefreshListViewV3<T>> {
  /// 刷新控制
  late EasyRefreshController _controller;

  /// 偏移量，用于计算加载数据的范围，拉取数据后刷新
  late int _offset;

  /// 单词拉取数
  late int _pullSize;

  /// 首次加载的数量
  late int _initSize;

  /// 已缓存数据，后续需优化最大缓存数
  final List<T> _cacheData = [];

  /// 数据转换撑的widget list
  final List<Widget> _itemList = [];

  /// builder 讲 data 转换为 widget
  late ItemBuilder<T> _itemBuilder;

  /// loader 实现数据加载逻辑
  late ItemLoader<T> _itemLoader;

  @override
  void initState() {
    _controller = widget._controller;
    _pullSize = widget._pullSize;
    _initSize = widget._initSize;
    _itemLoader = widget._itemLoader;
    _itemBuilder = widget._itemBuilder;

    _offset = 0;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
        onLoad: () {
          load();
        },
        onRefresh: () {
          refresh();
        },
        child: ListView(
          children: _itemList,
        ));
  }

  void refresh() {
    _doClear();
    load();
  }

  void load({int size = 0}) {
    int loadSize =
    size == 0 ? (_cacheData.isEmpty ? _initSize : _pullSize) : size;

    _itemLoader(_offset, loadSize).then((LoadResp<T> resp) {
      List<T> dataList = resp.dataList;
      pushBatch(dataList, refresh: true);
    });
  }

  void pushBatch(List<T> dataList, {bool refresh = false}) {
    for (var data in dataList) {
      pushOne(data);
    }
    if (refresh) {
      _doRefresh();
    }
  }

  void pushOne(T data, {bool refresh = false}) {
    this._cacheData.add(data);
    this._itemList.add(_itemBuilder(data, _offset));
    this._offset++;
    if (refresh) {
      _doRefresh();
    }
  }

  void _doClear() {
    _offset = 0;
    _cacheData.clear();
    _itemList.clear();
  }

  void _doRefresh() {
    setState(() {
      _cacheData;
      _itemList;
      _offset;
    });
  }
}
