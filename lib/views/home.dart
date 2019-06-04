
/// Created with Android Studio.
/// User: 三帆
/// Date: 16/01/2019
/// Time: 11:16
/// email: sanfan.hx@alibaba-inc.com
/// target:  app首页

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:aip_flutter/utils/shared_preferences.dart';
import 'package:aip_flutter/views/first_page/first_page.dart';
import 'package:aip_flutter/views/widget_page/widget_page.dart';
import 'package:aip_flutter/views/welcome_page/fourth_page.dart';
import 'package:aip_flutter/views/collection_page/collection_page.dart';
import 'package:aip_flutter/routers/application.dart';
import 'package:aip_flutter/utils/provider.dart';
import 'package:aip_flutter/model/widget.dart';
import 'package:aip_flutter/widgets/index.dart';
import 'package:aip_flutter/components/search_input.dart';
import 'package:aip_flutter/model/search_history.dart';
import 'package:aip_flutter/resources/widget_name_to_icon.dart';

// 颜色
const int ThemeColor = 0xFFC91B3A;


class AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<AppPage>
    with SingleTickerProviderStateMixin {

  // 本地持久化数据操作 工具类
  SpUtil sp;

  // 用什么
  WidgetControlModel widgetControl = new WidgetControlModel();

  // 历史数据列表
  SearchHistoryList searchHistoryList;

  //
  TabController controller;

  bool isSearch = false;

  String data = '无';
  String data2ThirdPage = '这是传给ThirdPage的值';
  String appBarTitle = tabData[0]['text'];

  static List tabData = [
    {'text': '动态', 'icon': new Icon(Icons.language)},
    {'text': '游记', 'icon': new Icon(Icons.extension)},
    {'text': '收藏', 'icon': new Icon(Icons.favorite)},
    {'text': '设置', 'icon': new Icon(Icons.import_contacts)}
  ];


  List<Widget> myTabs = [];

  @override
  void initState() {
    // 这都是自动调用的方法
    super.initState();

    initSearchHistory();

    controller = new TabController(
        initialIndex: 0, vsync: this, length: 4); // 这里的length 决定有多少个底导 submenus

    for (int i = 0; i < tabData.length; i++) {
      // 每一个tab 的配置
      myTabs.add(new Tab(text: tabData[i]['text'], icon: tabData[i]['icon']));
    }

    controller.addListener(() {

      // 监听 tab 的选择变动
      if (controller.indexIsChanging) {
        _onTabChange();
      }

    });

    Application.controller = controller;
  }

  @override
  void dispose() {
    // 回收内存
    controller.dispose();
    super.dispose();
  }

  initSearchHistory() async {
    sp = await SpUtil.getInstance();

    // 通过工具类 获取 本地的搜索数据
    String json = sp.getString(SharedPreferencesKeys.searchHistory);
    print("json $json");

    // 把json 转成 model数组
    searchHistoryList = SearchHistoryList.fromJSON(json);
  }

  void onWidgetTap(WidgetPoint widgetPoint, BuildContext context) {

    // 获取到 整个list 的数据源
    List widgetDemosList = new WidgetDemoList().getDemos();
    String targetName = widgetPoint.name;
    String targetRouter = '/category/error/404';

    widgetDemosList.forEach((item) {
      if (item.name == targetName) {
        targetRouter = item.routerName;
      }
    });

    // SearchHistory(name: targetName, targetRouter: targetRouter) 这是一个model
    // 为什么还要加上一个history
    searchHistoryList
        .add(SearchHistory(name: targetName, targetRouter: targetRouter));

    // 字符串用 $ 来拼接字符串
    print("searchHistoryList ${searchHistoryList.toString()}");

    // 导航 模块 导航到详情页
    Application.router.navigateTo(context, "$targetRouter");
  }

  Widget buildSearchInput(BuildContext context) {

    return new SearchInput((value) async {
      if (value != '') {
        List<WidgetPoint> list = await widgetControl.search(value);

        return list
            .map((item) => new MaterialSearchResult<String>(
          value: item.name,
          icon: WidgetName2Icon.icons[item.name] ?? null,
          text: 'widget',
          onTap: () {
            onWidgetTap(item, context);
          },
        ))
            .toList();
      } else {
        return null;
      }
    }, (value) {}, () {});

  }

  // 构建
  @override
  Widget build(BuildContext context) {
    // 本地数据库
    var db = Provider.db;

    // 脚手架
    return new Scaffold(
      // 顶部 bar
      appBar: new AppBar(title: buildSearchInput(context)),

      // 主体 tabbarview
      body: new TabBarView(controller: controller, children: <Widget>[
        new FirstPage(),
        new WidgetPage(db),
        new CollectionPage(),
        FourthPage()
      ]),

      // 底部 tabbar
      bottomNavigationBar: Material(
        // 整个控件颜色
        color: const Color(0xFFF0EEEF), //底部导航栏主题颜色

        // tabbar 子控件
        child: SafeArea(

          child: Container(
            // 高度
            height: 65.0,

            // 装饰
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFd0d0d0),
                  blurRadius: 3.0,
                  spreadRadius: 2.0,
                  offset: Offset(-1.0, -1.0),
                ),
              ],
            ),

            // tabbar 包含 controller + tabs
            child: TabBar(
                controller: controller,

                // 指示颜色
                indicatorColor: Theme.of(context).primaryColor,
                //tab标签的下划线颜色
                // labelColor: const Color(0xFF000000),
                indicatorWeight: 3.0,

                // 字体的不同状态下的颜色
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: const Color(0xFF8E8E8E),

                tabs: myTabs),
          ),
        ),
      ),

    );
  }

  // 这个界面相当于 uitabbar controller
  void _onTabChange() {
    if (this.mounted) {
      this.setState(() {
        // 每次选择 则 把title设置到 appbar上
        appBarTitle = tabData[controller.index]['text'];
      });
    }
  }
}
