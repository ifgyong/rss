import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyhub/flutter_easy_hub.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rss/dataCenter/table_column.dart';
import 'package:rss/models/HomeViewModel.dart';
import 'package:rss/route/articleModels/article_view_model.dart';
import 'package:rss/route/list_page_route.dart';
import 'package:rss/tools/tool.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '首页',
      theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.orange),
      home: ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        builder: (context, child) {
          return MyHomePage(
            title: 'RSS',
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FlutterEasyHub(
            child: SmartRefresher(
          controller: _controller,
          onRefresh: _listFresh,
          child: ListView.builder(
            itemBuilder: _cellBuild,
            itemCount: context.watch<HomeViewModel>().list.length,
          ),
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

  Widget _cellBuild(cts, index) {
    Map map = context.read<HomeViewModel>()[index];
    String title = map.containsKey('title') ? map['title'] : 'no data';
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
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
              height: 1,
              thickness: 0.5,
            )
          ],
        ),
      ),
      onTap: () {
        _clickCell(index);
      },
    );
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
  void _listFresh() async {
    await context.read<HomeViewModel>().loadData();
    _controller.refreshCompleted();
  }

  RefreshController _controller;
  TextEditingController _textEditingController;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      printY('show once');
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
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class HomeFreshUI {}
