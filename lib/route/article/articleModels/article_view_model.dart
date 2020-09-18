import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rss/dataCenter/data_center.dart';
import 'package:rss/tools/tool.dart';

///
/// Created by fgyong on 2020/9/17.
///

class ArticlViewModel extends ChangeNotifier {
  /// user id 根据这个查询文章个数 以及详情
  final String id;
  DataCenter _dataCenter;
  List<Map<String, dynamic>> list;

  ArticlViewModel({this.id}) : assert(id != null) {
    list ??= [];
    _dataCenter = DataCenter();
  }
  void loadData() async {
    list = await _dataCenter.selectArticles(id);
    notifyListeners();
  }

  /// 更新阅读数字
  Future<void> readArticle({String id, String atomUrl}) async {
    bool did = await _dataCenter.updateArticleDidRead(id: id);
    if (did) {
      _dataCenter.updateUserReadNumber(userId: atomUrl);
    }

    loadData();
  }
}
