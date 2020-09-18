import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_transition_animation/animation/fade.dart';
import 'package:flutter_transition_animation/easy_message.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rss/tools/tool.dart';
import 'package:webview_flutter/webview_flutter.dart';

///
/// Created by fgyong on 2020/9/15.
///

class ArtileDetailRoute extends StatefulWidget {
  final String title;
  final String content;
  final String url;
  ArtileDetailRoute({Key key, this.title, @required this.content, this.url})
      : super(key: key);

  @override
  _ArtileDetailRouteState createState() => _ArtileDetailRouteState();
}

class _ArtileDetailRouteState extends State<ArtileDetailRoute> {
  String _error;
  ValueKey<int> _errorKey = ValueKey(0);
  @override
  Widget build(BuildContext context) {
    Widget webview = Scaffold(
      body: WebviewScaffold(
        url: widget.url,
        appBar: AppBar(
          title: Text(widget.title ?? ''),
          bottom: progress == 1.0
              ? null
              : PreferredSize(
                  child: LinearProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).indicatorColor),
                    backgroundColor: Colors.white,
                  ),
                  preferredSize: Size.fromHeight(3.0),
                ),
        ),
        appCacheEnabled: true,
        scrollBar: true,
        // persistentFooterButtons: _bottom(),
        bottomNavigationBar: SafeArea(
          // key: _error != null ? ObjectKey(_error) : null,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 50,
                    child: Row(
                      children: _bottom(),
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    )),
                Positioned(
                  left: 0,
                  right: 0,
                  height: 50,
                  bottom: 0,
                  child: //     child: StreamBuilder<String>(
                      Container(
                    key: _errorKey,
                    alignment: Alignment.center,
                    child: FlutterEasyMessage(
                      shouldShow: _errorKey.value != 0,
                      messageChild: Container(
                        child: Text(
                          '$_error',
                          style: TextStyle(color: Colors.white),
                        ),
                        height: 44,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                      ),
                      duration: Duration(milliseconds: 1500),
                      hideAnimationStyle: EasyShowOrHideStyle.flip,
                      showAnimationStyle: EasyShowOrHideStyle.flip,
                      showAnimaitonDirection: EasyAnimationDirection.btt,
                      hideAnimaitonDirection: EasyAnimationDirection.ttb,
                    ),
                    // key: UniqueKey(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return webview;
  }

  List<Widget> _bottom() {
    return [
      FlatButton(
        child: Icon(Icons.keyboard_arrow_left),
        onPressed: () async {
          var back = await flutterWebViewPlugin.canGoBack();
          if (mounted && back) {
            flutterWebViewPlugin.goBack();
          } else if (back == false) {
            Navigator.of(context).maybePop();
          }
        },
      ),
      FlatButton(
        child: Icon(Icons.favorite_border),
        onPressed: () {},
      ),
      FlatButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          if (mounted) flutterWebViewPlugin.reload();
        },
      ),
      Builder(
        builder: (ctx) => FlatButton(
          child: Icon(Icons.keyboard_arrow_right),
          onPressed: () async {
            var go = await flutterWebViewPlugin.canGoForward();
            if (mounted && go) {
              flutterWebViewPlugin.goForward();
            } else if (go == false) {
              // _error.sink.add('已经装到南墙了');
              _error = '已经撞到南墙了😭';
              _errorKey = ValueKey(_errorKey.value + 1);
              setState(() {});
              // toast('已经撞到南墙了😭');
              // showOverlay((context, t) {
              //   return Opacity(
              //     opacity: t,
              //     child: IosStyleToast(),
              //   );
              // });
            }
          },
        ),
      )
    ];
  }

  Widget _widget() => CupertinoScrollbar(
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
      );
  Widget _body() {
    return Builder(
        builder: (context) => WebView(
              initialUrl: '${widget.url}',
              onPageStarted: (v) {
                printY('url load start: $v');
              },
              onPageFinished: (v) {
                printY('onPageFinished: $v');
              },
            ));
  }

  void _like() {}
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  var progress = 0.0;
  StreamSubscription<double> _onProgressChanged;
  StreamSubscription<double> _onScrollYChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;

  @override
  void initState() {
    _onProgressChanged = flutterWebViewPlugin.onProgressChanged.listen((event) {
      if (mounted)
        setState(() {
          progress = event;
        });
    });
    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      // if (mounted) {
      //   setState(() {
      //
      //   });
      // }
    });
    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _onProgressChanged.cancel();
    flutterWebViewPlugin.dispose();
    _onHttpError.cancel();
    _onScrollYChanged.cancel();
    super.dispose();
  }
}
