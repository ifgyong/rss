import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyhub/flutter_easy_hub.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///
/// Created by fgyong on 2020/9/18.
///
import 'dart:io';
import 'package:rss/route/article/list_page_route.dart';
import 'package:rss/route/home/models/HomeViewModel.dart';
import 'package:rss/tools/tool.dart';
import 'package:rss/dataCenter/table_column.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Widget> _listWidgets = [];
  @override
  Widget build(BuildContext context) {
    int length = context.watch<HomeViewModel>().list.length;
    if (_listWidgets.isNotEmpty) {
      _listWidgets.clear();
    }
    printY('$length');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FlutterEasyHub(
            child: EasyRefresh(
          // controller: _controller,
          controller: _refreshController,
          onRefresh: _listFresh,
          child: _body(length),
          emptyWidget: length == 0
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 60, right: 60),
                        child: FlatButton(
                          child: Text(
                            '没有订阅资源\n 点击添加',
                            textAlign: TextAlign.center,
                          ),
                          onPressed: _showDia,
                        ),
                      )
                    ],
                  ),
                )
              : null,
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDia,
        tooltip: '添加',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _body(int length) {
    return CustomScrollView(
      slivers: [
        SliverAnimatedList(
          key: ObjectKey(Object()),
          itemBuilder: _cellBuildAnimation,
          initialItemCount: length,
        )
      ],
    );
  }

  /// Animation<double> animation
  ///
  Widget _cellBuildAnimation(
      BuildContext context, int index, Animation<double> animation) {
    return _cellBuild(context, index);
  }

  Widget _cellBuild(BuildContext context, int index) {
    Map map = context.read<HomeViewModel>()[index];
    String title = map.containsKey('title') ? map['title'] : 'no data';
    Widget cell = InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text('$title'),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Text.rich(TextSpan(
                    text: '${map['unReadNumber'] ?? '-'} ',
                    style: TextStyle(color: Colors.pink[300], fontSize: 20),
                    children: [
                      TextSpan(
                        text: '/',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      TextSpan(
                        text: '  ${map['readNumber'] ?? '-'}',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ])),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              indent: 0,
              height: 0.3,
              thickness: 0.3,
            )
          ],
        ),
      ),
      onTap: () {
        _clickCell(index);
      },
    );

    Widget slidable = Slidable(
      child: cell,
      actionPane: SlidableScrollActionPane(),
      controller: slidableController,
      actionExtentRatio: 0.18,
      key: ValueKey(index),
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onWillDismiss: (type) {
          return showDialog<bool>(
            context: context,
            builder: (context) {
              return Platform.isIOS
                  ? CupertinoAlertDialog(
                      title: Text('Delete'),
                      content: Text('Item will be deleted'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    )
                  : AlertDialog(
                      title: Text('Delete'),
                      content: Text('Item will be deleted'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
            },
          );
        },
      ),
      secondaryActions: [
        IconSlideAction(
          // caption: '收藏',
          // color: Colors.blueAccent,
          icon: Icons.favorite_border,

          onTap: () {
            _slidableLike(index);
          },
          foregroundColor: Colors.red,
        ),
        IconSlideAction(
          // caption: '删除',
          color: Colors.black12,
          icon: Icons.delete,
          onTap: () {
            _showDeleteDialog(index, contextt1: context);
          },
        ),
      ],
    );
    _listWidgets.add(slidable);
    return slidable;
  }

  /// 展示删除 Dialog
  void _showDeleteDialog(int index, {BuildContext contextt1}) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: const Text('删除'),
                  content: const Text('确定删除该选项'),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    FlatButton(
                      child: const Text('删除'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteItem(index, contextt1);
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: const Text('删除'),
                  content: const Text('确定删除该选项'),
                  actions: <Widget>[
                    FlatButton(
                      child: const Text('取消'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    FlatButton(
                      child: const Text('删除'),
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        _deleteItem(index, contextt1);
                      },
                    ),
                  ],
                );
        });
  }

  /// 删除 Dialog
  void _deleteItem(int index, BuildContext context) {
    SliverAnimatedList.of(context).removeItem(index, (context, animation) {
      return SizeTransition(
        child: _listWidgets[index],
        sizeFactor: animation,
      );
    });
  }

  void _slidableLike(int index) {
    printY('喜欢');
  }

  void _clickCell(int index) {
    Map map = context.read<HomeViewModel>()[index];
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ListPageRouteProvider(
        autoUrl: map['${UserRolumns.autoUrl}'],
        author: map['${UserRolumns.name}'] ?? '',
        title: map['${UserRolumns.title}'] ?? '',
      ),
    ));
  }

  void _showDia() {
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          Widget widget = Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            constraints: BoxConstraints(maxHeight: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            // height: 200,
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    '添加订阅',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.black54,
                        fontSize: 15),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 40,
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoTextField(
                            placeholder: '输入订阅url',
                            controller: _textEditingController,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            alignment: Alignment.center,
                            child: Container(
                              width: 120,
                              child: FlatButton(
                                child: Text('获取'),
                                onPressed: _addRss,
                                color: Theme.of(context).buttonColor,
                                textColor: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 43,
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
          return Center(
            child: widget,
          );
        });
  }

  /// 添加rss加载数据
  void _addRss() async {
    String url = _textEditingController.value.text;
    await context.read<HomeViewModel>().addRss('$url');
    Navigator.of(context).maybePop();
  }

  /// 下拉刷新
  Future<void> _listFresh() async {
    context.read<HomeViewModel>().loadData().then((value) {
      _refreshController.finishRefresh();
    });
    // _controller.refreshCompleted();
  }

  RefreshController _controller;
  TextEditingController _textEditingController;
  final SlidableController slidableController = SlidableController();
  EasyRefreshController _refreshController;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<HomeViewModel>(context, listen: false)
        ..loadDataLocal()
        ..addListener(() {
          HomeViewModel viewModel =
              Provider.of<HomeViewModel>(context, listen: false);
          if (viewModel.error.isNotEmpty) {
            EasyHub.showErrorHub(viewModel.error);
          } else if (viewModel.success.isNotEmpty) {
            EasyHub.showCompleteHub(viewModel.success);
          }
        });
    });
    _controller = RefreshController(initialRefresh: false);
    _textEditingController = TextEditingController();

    WidgetsBinding.instance.addObserver(this);
    _refreshController = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
