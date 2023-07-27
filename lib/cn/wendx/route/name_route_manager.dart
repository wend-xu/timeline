import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:timeline/cn/wendx/page/layout_page.dart';
import 'package:timeline/cn/wendx/page/test_page.dart';
import 'package:timeline/cn/wendx/page/timeline_page.dart';
import 'package:timeline/cn/wendx/page/timeline_search_page.dart';

class R {
  static const String timeline = "timeline";
  static const String timelineSearch = "timeline_search";
  static const String testPage = "testPage";
  static const String layoutPage = "layoutPage ";

  static final Map<String, WidgetBuilder> _routeMap = {
    timeline: (context) => TimelinePage(),
    timelineSearch: (context) => TimelineSearchPage(),
    testPage: (context) => TestPage(),
    layoutPage: (context) => LayoutPage(),
  };

  static Map<String, WidgetBuilder> routes() {
    return _routeMap;
  }
}
