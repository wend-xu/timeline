import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/page/layout_page.dart';
import 'package:timeline/cn/wendx/page/quill_demo.dart';
import 'package:timeline/cn/wendx/page/test_page.dart';
import 'package:timeline/cn/wendx/page/timeline_search_page.dart';

// import '../page/quill_demo.dart';


class R {
  static const String timeline = "timeline";
  static const String timelineSearch = "timeline_search";
  static const String testPage = "testPage";
  static const String layoutPage = "layoutPage ";
  static const String quillDemo = "quillDemo";

  static final Map<String, WidgetBuilder> _routeMap = {
    // timeline: (context) => TimelinePage(),
    timelineSearch: (context) => TimelineSearchPage(),
    testPage: (context) => TestPage(),
    layoutPage: (context) => LayoutPage(),
    quillDemo: (context) =>QuillDemo(),
  };

  static Map<String, WidgetBuilder> routes() {
    return _routeMap;
  }
}
