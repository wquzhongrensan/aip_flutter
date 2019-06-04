///
/// Created with Android Studio.
/// User: 三帆
/// Date: 18/02/2019
/// Time: 14:19
/// email: sanfan.hx@alibaba-inc.com
/// target: 搜索WidgetDemo中的历史记录model
///

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:aip_flutter/utils/user_default.dart';


// 纯粹是一个数据结构
class SearchHistory {
  // 两个属性
  // 名称
  final String name;

  // 跳转的目标页
  final String targetRouter;

  // 构造函数 必传字段
  SearchHistory({@required this.name, @required this.targetRouter});
}

class SearchHistoryList {

  // 工具类 和 实例
  static SpUtil _sp;
  static SearchHistoryList _instance;

  // 搜索历史 数据源
  static List<SearchHistory> _searchHistoryList = [];

  static SearchHistoryList _getInstance(SpUtil sp) {
    if (_instance == null) {
      _sp = sp;
      String json = sp.get(SharedPreferencesKeys.searchHistory);
      _instance = new SearchHistoryList.fromJSON(json);
    }

    return _instance;
  }

  factory SearchHistoryList([SpUtil sp]) {
    if (sp == null && _instance == null) {
      print(new ArgumentError(
          ['SearchHistoryList need instantiatied SpUtil at first timte ']));
    }
    return _getInstance(sp);
  }

//  List<SearchHistory> _searchHistoryList = [];

  // 存放的最大数量
  int _count = 10;

  SearchHistoryList.fromJSON(String jsonData) {
    _searchHistoryList = [];
    if (jsonData == null) {
      return;
    }
    List jsonList = json.decode(jsonData);
    jsonList.forEach((value) {
        // arr. add()
      _searchHistoryList.add(SearchHistory(
          name: value['name'], targetRouter: value['targetRouter']));

    });
  }

  List<SearchHistory> getList() {
    return _searchHistoryList;
  }

  clear() {
    // 本地的
    _sp.remove(SharedPreferencesKeys.searchHistory);
    // 内存上的
    _searchHistoryList = [];
  }

  save() {
    // key - value 存值
    _sp.putString(SharedPreferencesKeys.searchHistory, this.toJson());
  }

  add(SearchHistory item) {
    print("_searchHistoryList> ${_searchHistoryList.length}");

    for (SearchHistory value in _searchHistoryList) {
      // 存过 就  不再存
      if (value.name == item.name) {
        return;
      }
    }

    // 这里可以再优化  LRU策略
    if (_searchHistoryList.length > _count) {
      _searchHistoryList.removeAt(0);
    }
    _searchHistoryList.add(item);
    save();
  }

  toJson() {

    // map 是 key -value
    List<Map<String, String>> jsonList = [];

    _searchHistoryList.forEach((SearchHistory value) {
      jsonList.add({'name': value.name, 'targetRouter': value.targetRouter});
    });

    // 系统原有模块
    return json.encode(jsonList);
  }

  @override
  String toString() {
    return this.toJson();
  }
}
