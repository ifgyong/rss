import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rss/dataCenter/data_center.dart';
import 'package:rss/main.dart';
import 'package:rss/route/article/articleModels/article_view_model.dart';
import 'package:rss/route/article/artile_detail.dart';
import 'package:rss/route/home/models/HomeViewModel.dart';
import 'package:rss/tools/event_buses.dart';
import 'package:rss/tools/tool.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

///
/// Created by fgyong on 2020/9/15.
///
///
class ListPageRouteProvider extends StatelessWidget {
  final String autoUrl;
  final String author;
  final String title;
  ListPageRouteProvider({this.autoUrl, this.author, this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ArticlViewModel(id: autoUrl),
        child: ListPageRoute(
          title: this.title ?? '',
          author: author,
          autoUrl: autoUrl,
        ));
  }
}

class ListPageRoute extends StatefulWidget {
  final String title;
  final String author;
  final String autoUrl;

  ListPageRoute({Key key, this.title, this.author, this.autoUrl})
      : super(key: key);

  @override
  _ListPageRouteState createState() => _ListPageRouteState();
}

class _ListPageRouteState extends State<ListPageRoute> {
  List<Map<String, dynamic>> list;

  String titleOf(int index) => list[index]['title'] ?? '';
  String contentOf(int index) => list[index]['content'] ?? '';
  String idOf(int index) => list[index]['id'] ?? '';
  String urlOf(int index) => list[index]['link'] ?? '';

  String pushTime(int index) => list[index]['updateTime'] ?? '';

  bool didrRead(int index) => '${list[index]['read']}' == '1' ? true : false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '列表页'),
      ),
      body: WillPopScope(
          child: _body(),
          onWillPop: () async {
            eventBus.fire(HomeFreshUI());
            return true;
          }),
    );
  }

  Widget _body() {
    return SafeArea(
      bottom: false,
      child: CupertinoScrollbar(
        child: Selector<ArticlViewModel, List<Map<String, dynamic>>>(
          builder: (context, model, child) {
            list = model;
            return ListView.builder(
              itemBuilder: _cellBuilder,
              itemCount: model.length,
            );
          },
          selector: (context, m) => m.list,
          shouldRebuild: (pro, curr) => pro.toString() != curr.toString(),
        ),
      ),
    );
  }

  Widget _cellBuilder(context, index) {
    Map<String, dynamic> element = list[index];
    return InkWell(
      child: Container(
        height: 80,
        margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.black12,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              top: 10,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              didrRead(index)
                                  ? SizedBox(
                                      width: 10,
                                    )
                                  : Container(
                                      width: 6,
                                      height: 6,
                                      margin:
                                          EdgeInsets.only(right: 10, left: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                      ),
                                    ),
                              Expanded(
                                child: Text(
                                  '${element['title'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                children: <Widget>[
                  didrRead(index)
                      ? SizedBox(
                          width: 10,
                        )
                      : SizedBox(
                          width: 26,
                        ),
                  Text('${pushTime(index)}'),
                  Text(' | '),
                  Text(' ${widget.author ?? ''}')
                ],
              ),
            )
          ],
        ),
      ),
      onTap: () {
        _cellClick(index);
      },
    );
  }

  void _cellClick(int index) async {
    // if (await canLaunch(urlOf(index))) {
    //   await launch(urlOf(index));
    // }
    printY('${urlOf(index)}');
    context
        .read<ArticlViewModel>()
        .readArticle(id: idOf(index), atomUrl: widget.autoUrl);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ArtileDetailRoute(
              content: contentOf(index),
              title: '${titleOf(index)}',
              url: urlOf(index),
            )));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ArticlViewModel>(context, listen: false).loadData();
    });
    super.initState();
  }
}
