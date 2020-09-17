import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

///
/// Created by fgyong on 2020/9/15.
///

class ArtileDetailRoute extends StatefulWidget {
  final String title;
  final String content;
  ArtileDetailRoute({Key key, this.title, @required this.content})
      : super(key: key);

  @override
  _ArtileDetailRouteState createState() => _ArtileDetailRouteState();
}

class _ArtileDetailRouteState extends State<ArtileDetailRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoScrollbar(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: false, floating: true,
              // title: Text(widget.title ?? '详情'),
              actions: <Widget>[
                CupertinoButton(
                    child: Icon(
                      Icons.label_outline,
                      color: Colors.white,
                    ),
                    onPressed: _like)
              ],
            ),
            SliverToBoxAdapter(
                child: Container(
              // alignment: Alignment.center,
              margin: EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${widget.title}',
                      style: TextStyle(
                        fontSize: 23,
                      ),
                    ),
                  )
                ],
              ),
            )),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('2019-12-24'),
                    SizedBox(
                      width: 10,
                    ),
                    Text('fgyong')
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _body(),
            )
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Html(
        data: widget.content,
      ),
      margin: EdgeInsets.only(left: 10, right: 10),
    );
  }

  void _like() {}
}
