import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

typedef ItemBuilder<T> = Widget Function(T t, int index);

typedef ItemLoader<T> = Future<LoadResp<T>> Function(int offset, int limit);

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

class RefreshListViewController<T> {
  RefreshListViewState<T>? refreshListViewV3State;

  void bind(RefreshListViewState<T> refreshListViewV3State) {
    this.refreshListViewV3State = refreshListViewV3State;
  }

  void refresh() {
    refreshListViewV3State?.refresh();
  }

  void load({int size = 0}) {
    refreshListViewV3State?.load(size: size);
  }

  void sendBatch(List<T> dataList, {bool refresh = false}) {
    refreshListViewV3State?.unshiftBatch(dataList, refresh: refresh);
  }

  void send(T data, {bool refresh = false}) {
    refreshListViewV3State?.unshift(data, refresh: refresh);
  }
}

/// EasyRefresh  提供的是触发 下拉加载 和 上滑刷新 的功能
/// 数据的加载和维护还是得自行处理
/// 不要用listView的builder方法，直接传入维护的数据
class RefreshListView<T> extends StatefulWidget {
  final RefreshListViewController<T>? _controller;

  final int _pullSize;

  final int _initSize;

  final ItemBuilder<T> _itemBuilder;

  final ItemLoader<T> _itemLoader;

  RefreshListView({
    RefreshListViewController<T>? controller,
    int? pullSize,
    int? initSize,
    required ItemBuilder<T> itemBuilder,
    required ItemLoader<T> itemLoader,
  })  : _controller = controller,
        _pullSize = pullSize ?? 20,
        _initSize = initSize ?? 10,
        _itemBuilder = itemBuilder,
        _itemLoader = itemLoader;

  @override
  State<StatefulWidget> createState() {
    return RefreshListViewState<T>();
  }
}

class RefreshListViewState<T> extends State<RefreshListView<T>> {
  static final Logger _log = Logger();

  /// 控制器
  late RefreshListViewController<T>? _controller;

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

  late EasyRefreshController _easyRefreshController;

  late ScrollController _scrollController;

  var _listKey = 0;

  @override
  void initState() {
    _pullSize = widget._pullSize;
    _initSize = widget._initSize;
    _itemLoader = widget._itemLoader;
    _itemBuilder = widget._itemBuilder;

    _offset = 0;

    if (widget._controller != null) {
      _controller = widget._controller;
      _controller!.bind(this);
    }

    _easyRefreshController = EasyRefreshController(
      controlFinishLoad: true,
    );
    _scrollController = ScrollController();

  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_cacheData.length == 0) {
        _easyRefreshController.callLoad().then((value) => _animateToLatest());
      } else {
        // _easyRefreshController.finishLoad(IndicatorResult.noMore);
        //_animateToBottom().then((value) => _easyRefreshController.finishLoad(IndicatorResult.success));
      }
    });
    _log.i("数据尺寸： ${_cacheData.length} offset:$_offset");
    return EasyRefresh(
        controller: _easyRefreshController,
        onLoad: () async {
          await load();
        },
        onRefresh: () async {
          refresh();
        },
        child: ListView.builder(
          reverse: true,
            controller: _scrollController,
            itemCount: _cacheData.length,
            itemBuilder: (context, index) {
              return _itemBuilder(_cacheData[index], index);
            }));
  }

  void refresh() {
    _doClear();
    load();
  }

  /// return ture has more
  Future<bool> load({int size = 0}) async {
    _log.i("调用了load");
    int loadSize =
        size == 0 ? (_cacheData.isEmpty ? _initSize : _pullSize) : size;

    LoadResp<T> resp = await _itemLoader(_offset, loadSize);
    List<T> dataList = resp.dataList;
    pushBatch(dataList);
    bool hasMore = resp.total > _cacheData.length;
    _easyRefreshController.finishLoad();
    // _easyRefreshController.finishLoad(hasMore?IndicatorResult.success:IndicatorResult.noMore);
    return hasMore;
  }

  void pushBatch(List<T> dataList){
    this._cacheData.addAll(dataList);
    this._offset += dataList.length;
    _doRefresh();
  }

  void unshiftBatch(List<T> dataList, {bool refresh = false}) {
    this._cacheData.insertAll(0,dataList);
    this._offset += dataList.length;
    _doRefresh();
  }

  void unshift(T data, {bool refresh = false}) {
    this._cacheData.insert(0,data);
    this._offset++;
    if (refresh) {
      this._doRefresh();
    }
  }

  void _doClear() {
    _offset = 0;
    _cacheData.clear();
    _itemList.clear();
  }

  void _doRefresh() {
    setState(() {
      // _animateToBottom();
    });
  }

  Future<void> _animateToBottom() {
    return _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  Future<void> _animateToLatest() {
    return _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }
}
