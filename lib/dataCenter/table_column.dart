import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Created by fgyong on 2020/9/17.
///

class UserRolumns {
  static String get title => 'title';

  static String get subtitle => 'subtitle';

  static String get home => 'home';

  static String get id => 'id';

  static String get name => 'name';

  /// 一共书文章
  static String get readNumber => 'readNumber';

  /// 未读文章数量
  static String get unReadNumber => 'unReadNumber';
  static String get autoUrl => 'autourl';

  static List<String> get all =>
      [id, autoUrl, title, subtitle, home, name, readNumber, unReadNumber];
}

/// 文章数据
class ArticleRolumns {
  static String get title => 'title';

  static String get userid => 'userid';

  static String get link => 'link';

  static String get id => 'id';

  static String get read => 'read';
  static String get updateTime => 'updateTime';

  static String get content => 'content';
  static String get summary => 'summary';

  static List<String> get all =>
      [title, userid, id, read, link, updateTime, content, summary];
}
