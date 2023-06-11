import 'package:flutter/material.dart';
import 'package:timeline/cn/wendx/page/timeline_page.dart';
import 'package:timeline/cn/wendx/page/timeline_search_page.dart';

class R {
  static const String timeline = "timeline";
  static const String timelineSearch = "timeline_search";

  static final Map<String, WidgetBuilder> _routeMap = {
    timeline: (context) => TimelinePage(),
    timelineSearch: (context) => TimelineSearchPage()
  };


  static Map<String, WidgetBuilder> routes() {
    return _routeMap;
  }
}
