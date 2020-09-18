import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rss/dataCenter/data_center.dart';
import 'package:rss/dataCenter/table_column.dart';
import 'package:rss/tools/event_buses.dart';
import 'package:rss/tools/tool.dart';
import 'package:xml/xml.dart';

///
/// Created by fgyong on 2020/9/16.
///
///
class ReadArtitle {
  final String id;

  /// 读某个文章
  ReadArtitle(this.id);
}

EventBus eventBus = EventBus();

class HomeViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> list;
  File file;

  String error = '';
  String success = '';

  DataCenter _center;
  HomeViewModel() : super() {
    list ??= [];
    _center = DataCenter()..createDBIfNotExist();

    /// 加载本地数据
    eventBus.on<HomeFreshUI>().listen((event) {
      loadDataLocal();
    });
  }

  Future<bool> insertUser(
      {String title = '',
      String subtitle = '',
      String home = '',
      String name = '',
      int read = 0,
      int unread = 0}) async {
    return _center.insertUser(
        title: title,
        subtitle: subtitle,
        home: home,
        name: name,
        read: read,
        unread: unread);
  }

  /// 加载本地数据
  Future<void> loadDataLocal({bool shouldNotification = true}) async {
    try {
      await _center.createDBIfNotExist();
      list = await _center.selectUsers();
      if (shouldNotification == true) notifyListeners();
    } catch (e) {}
  }

  /// 重新下载数据
  Future<void> loadData() async {
    try {
      List<Map<String, dynamic>> maps = await _center.selectUsers();
      for (int i = 0; i < maps.length; i++) {
        Map<String, dynamic> map = maps[i];
        if (map.containsKey('${UserRolumns.autoUrl}')) {
          await addRss(map['${UserRolumns.autoUrl}'],
              shouldNotification: false);
          await _center.updateUserReadNumber(
              userId: map['${UserRolumns.autoUrl}']);
        }
      }
      list = await _center.selectUsers();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> addRss(String url, {bool shouldNotification = true}) async {
    if (url.isNotEmpty) {
      bool have = await _center.usersContainsId(md5ToKey(url: url));
      if (have == false) {
        loadAndSaveInfo(url, shouldNotification: shouldNotification);
      } else {
        error = '该订阅已存在';
        if (shouldNotification == true) {
          notifyListeners();
        }

        error = '';
      }
      printY('homeviewmodel:是否已经有该订阅数据： $have');
    } else {
      error = '订阅不可为空';
      if (shouldNotification == true) {
        notifyListeners();
      }
      error = '';
    }
  }

  void loadAndSaveInfo(String url, {bool shouldNotification = true}) async {
    var resposne = await Dio().get(url);
    String xml = resposne.data;

    try {
      Map<String, dynamic> map = {'${UserRolumns.autoUrl}': url};

      var root = XmlDocument.parse(xml);

      var title = root.findAllElements('${UserRolumns.title}');
      if (title.length > 0) {
        map['${UserRolumns.title}'] = '${title.first.text}';
      }

      var subitle = root.findAllElements('${UserRolumns.subtitle}');
      if (subitle.length > 0) {
        map['${UserRolumns.subtitle}'] = '${subitle.first.text}';
      }

      var authos = root.findAllElements('${UserRolumns.name}');
      String ah = '';
      if (authos != null && authos.length > 0) {
        ah = authos.first.text;
      }
      map['${UserRolumns.name}'] = '$ah';

      var links = root.findAllElements('id').toList();
      links
        ..where((element) =>
            element.text.matchAsPrefix('http').start == 0 ||
            element.text.matchAsPrefix('https').start == 0);
      if (links.length > 0) {
        map['${UserRolumns.home}'] = '${links[0].text}';
      }

      List<Map<String, dynamic>> subList = List<Map<String, dynamic>>();

      List nodes = root.findAllElements('entry').toList();
      map['readNumber'] = nodes.length;
      map['unReadNumber'] = nodes.length;

      root.findAllElements('entry').toList().forEach((element) {
        /// published
        /// title
        /// link
        /// summary
        /// content
        /// read 0未读 1已读
        Map<String, dynamic> sub = Map<String, dynamic>();
        sub['title'] = element.findElements('title').first.text ?? '';
        sub['link'] = element.findElements('id').first.text ?? '';
        sub['published'] =
            element.findElements('published').first.text.substring(0, 10) ?? '';
        sub['summary'] = element.findElements('summary').first.text ?? '';
        sub['content'] = element.findElements('content').first.text ?? '';
        sub['id'] = md5ToKey(url: sub['content'].toString());
        subList.add(sub);
      });

      if (subList.length > 0) {
        String userKey = md5ToKey(url: url);
        map['id'] = userKey ?? '';
        await _center.insertUserMap(map);
        String currentUserId = await _center.getUserId(url);

        for (var i = 0; i < subList.length; ++i) {
          var item = subList[i];

          /// 绑定文章id和user
          item['${ArticleRolumns.userid}'] = currentUserId;
          await _center.insertArticleMap(item);
        }
        loadDataLocal(shouldNotification: shouldNotification);
      }
    } on DioErrorType catch (e) {
      if (e == DioErrorType.CANCEL) {
        error = '网络取消';
      } else if (e == DioErrorType.RESPONSE) {
        error = '没找到资源';
      } else if (e == DioErrorType.CONNECT_TIMEOUT ||
          e == DioErrorType.SEND_TIMEOUT) {
        error = '网络超时';
      } else if (e == DioErrorType.DEFAULT) {
        error = '网络错误';
        print(e.toString());
      }
      notifyListeners();
      error = '';
    } catch (e) {
      error = '网络错误';

      notifyListeners();
      error = '';
      print(e.toString());
    }
  }

  String md5ToKey({String url}) {
    return md5.convert(utf8.encode(url)).toString();
  }

  operator [](int index) {
    if (index >= 0 || index < list.length) {
      return list[index];
    }
    return null;
  }

  int readNumber(int index) {
    if (index >= 0 || index < list.length) {
      Map map = list[index];
      if (map['data']) {}
    }
  }

  void read(String id) {
    _center.updateArticleDidRead(id: id);
  }
}
