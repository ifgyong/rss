import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rss/dataCenter/table_column.dart';
import 'package:rss/tools/tool.dart';
import 'package:sqflite/sqflite.dart';

///
/// Created by fgyong on 2020/9/16.
///

class DataCenter {
  Future<String> fullDataBasesPath() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/data.db';
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}
    printY('dataBase: $path');
    return path;
  }

  Database _database;

  String _userName = 'user';
  String _articleListName = 'artitle';

  static DataCenter _dataCenter = DataCenter._();
  factory DataCenter() => _dataCenter;

  DataCenter._() {
    // if (_dataCenter == null) {
    //   _dataCenter = _instance();
    // }
    createDBIfNotExist();
  }

  /// 如果不存在DB就创建文件
  Future<Database> createDBIfNotExist() async {
    String fullpath = await fullDataBasesPath();
    if (_database == null) {
      Database db = await openDatabase(fullpath,
          version: 1, onCreate: _onCreate, onConfigure: _onConfigure);
      _database = db;
      printY('_database is null,now open it');
    }
    return _database;
  }

  /// 打开外键
  _onConfigure(Database db) async {
    // await db.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    try {
      db.execute('''
        CREATE TABLE $_userName (
            id TEXT PRIMARY KEY, 
            ${UserRolumns.title} TEXT, 
            ${UserRolumns.subtitle} TEXT, 
            ${UserRolumns.home} TEXT, 
            ${UserRolumns.name} TEXT,
            ${UserRolumns.autoUrl} TEXT,
            ${UserRolumns.readNumber}  int,
            ${UserRolumns.unReadNumber} int
               )
        ''');
      db.close();
      db.execute('''
      CREATE TABLE $_articleListName (
            id TEXT PRIMARY KEY, 
            ${ArticleRolumns.userid}  TEXT,
            ${ArticleRolumns.title} TEXT, 
            ${ArticleRolumns.link} TEXT, 
            ${ArticleRolumns.content} TEXT,
            ${ArticleRolumns.summary} TEXT,
            ${ArticleRolumns.updateTime} TEXT,   
            ${ArticleRolumns.read}  int
               )
      ''');
    } catch (_) {}
  }

  /// 插入rss 信息
  Future<bool> insertUser({
    String title = '',
    String subtitle = '',
    String home = '',
    String name = '',
    int read = 0,
    int unread = 0,
    String id = '',
  }) async {
    int idx = await _database.insert(_userName, {
      'title': '$title',
      'subtitle': '$subtitle',
      'home': '$home',
      'name': '$name',
      'readNumber': read,
      'unReadNumber': unread,
      'id': id,
    });
    return idx < 0;
  }

  Future<bool> insertUserMap(Map<String, dynamic> map) async {
    int have = (await _database.query(_userName,
            where: '${UserRolumns.id} = ?', whereArgs: ['${map['id']}']))
        .length;
    if (have == 0) {
      int id = await _database.insert(_userName, map);
      return id < 0;
    } else {
      return true;
    }
  }

  Future<bool> insertArticleMap(Map map) async {
    int have = (await _database.query(_articleListName,
            where: '${ArticleRolumns.id} = ?', whereArgs: ['${map['id']}']))
        .length;
    if (have == 0) {
      int id = await _database.insert(_articleListName, {
        ArticleRolumns.title: '${map[ArticleRolumns.title] ?? ''}',
        ArticleRolumns.userid: '${map[ArticleRolumns.userid] ?? ''}',
        ArticleRolumns.read: 0,
        ArticleRolumns.content: '${map[ArticleRolumns.content] ?? ''}',
        ArticleRolumns.summary: '${map[ArticleRolumns.summary] ?? ''}',
        ArticleRolumns.link: '${map[ArticleRolumns.link] ?? ''}',
        ArticleRolumns.id: '${map[ArticleRolumns.id]}',
        ArticleRolumns.updateTime: '${map["published"] ?? ''}'
      });
      return id < 0;
    } else {
      return true;
    }
  }

  /// 添加多个文章
  Future<bool> insertArticleRow(
      {String title = '',
      String userid = '',
      String published = '',
      String content = '',
      String summary = '',
      String link = ''}) async {
    int have = (await _database.query(_articleListName,
            where: '${ArticleRolumns.link} = ?', whereArgs: ['$link']))
        .length;
    if (have > 0) {
      /// 有则更新
      int id = await _database.update(
          _articleListName,
          {
            ArticleRolumns.title: '$title',
            ArticleRolumns.userid: '$userid',
            ArticleRolumns.content: '$content',
            ArticleRolumns.summary: '$summary',
          },
          where: '${ArticleRolumns.link} = ?',
          whereArgs: ['$link']);
      printY('更新 文章');
      return id > 0;
    } else {
      int id = await _database.insert(_articleListName, {
        ArticleRolumns.title: '$title',
        ArticleRolumns.userid: '$userid',
        ArticleRolumns.read: 0,
        ArticleRolumns.content: '$content',
        ArticleRolumns.summary: '$summary',
        ArticleRolumns.link: '$link'
      });
      return id < 0;
    }
  }

  /// 更新文章已读

  Future<bool> updateArticleDidRead({String id}) async {
    int ret = await _database.update(_articleListName, {ArticleRolumns.read: 1},
        where: '${ArticleRolumns.id} = ?', whereArgs: ['$id']);
    return ret > 0;
  }

  /// 根据url 查询id
  Future<String> getUserId(String url) async {
    return '$url';
    // List<Map> maps = await _database.query(_userName,
    //     columns: ['${UserRolumns.autoUrl}'],
    //     where: '${UserRolumns.autoUrl} = ?',
    //     whereArgs: ['$url']);
    // if (maps.length > 0) {
    //   if (maps[0] is Map) {
    //     if (maps[0].containsKey('id')) {
    //       return '${maps[0]['id']}';
    //     }
    //   }
    // }
    // return null;
  }

  /// 是否包含该rss url
  Future<bool> usersContainsId(String key) async {
    int have = (await _database.query(_userName,
            where: '${UserRolumns.id} = ?', whereArgs: ['$key}']))
        .length;
    return have > 0;
  }

  /// 更新 rss 已读和未读数量
  Future<bool> updateUserReadNumber({String userId}) async {
    List<Map> alls = await _database.query(_articleListName,
        where: '${ArticleRolumns.userid} = ?  ', whereArgs: ['$userId']);
    List<Map> reads = await _database.query(_articleListName,
        where: '${ArticleRolumns.userid}  = ? and ${ArticleRolumns.read} = 1',
        whereArgs: ['$userId']);

    int ret = await _database.update(
        _userName, {'${UserRolumns.readNumber}': alls.length ?? 0},
        where: '${UserRolumns.autoUrl} = ?', whereArgs: ['$userId']);

    int ret2 = await _database.update(_userName,
        {'${UserRolumns.unReadNumber}': alls.length - reads.length ?? 0},
        where: '${UserRolumns.autoUrl} = ?', whereArgs: ['$userId']);
    return ret > 0 && ret2 > 0;
  }

  /// 查询所有 添加的rss
  Future<List<Map<String, dynamic>>> selectUsers() async {
    List<Map<String, dynamic>> maps =
        await _database.query(_userName, columns: UserRolumns.all);
    return maps.toList();
  }

  /// 查询 文章
  Future<List<Map<String, dynamic>>> selectArticles(String usereId) async {
    List<Map<String, dynamic>> maps = await _database.query(_articleListName,
        columns: ArticleRolumns.all,
        where: '${ArticleRolumns.userid} = ?',
        whereArgs: ['$usereId']);
    return maps.toList();
  }

  Future close() async => _database.close();
  //
  // /// 创建文件
  // static Future<void> createFile() async {
  //   String full = await fullPath;
  //   Directory currentPath = Directory(full);
  //   currentPath.exists().then((value) {
  //     if (value == false) {
  //       try {
  //         File f = File(currentPath.path);
  //         f.exists().then((value) {
  //           if (value == false) {
  //             f.writeAsStringSync('[]');
  //             print('覆盖文件');
  //             print('$value');
  //           }
  //         });
  //       } catch (e) {
  //         print(e);
  //       }
  //     }
  //   });
  // }
  //
  // /// 获取json文件
  // static Future<File> jsonFile() async {
  //   return File(await fullPath);
  // }
  //
  // static Future<String> get fullPath async {
  //   var path;
  //   if (Platform.isAndroid) {
  //     path = await getTemporaryDirectory();
  //   } else if (Platform.isIOS) {
  //     path = await getTemporaryDirectory();
  //   } else {
  //     throw UnsupportedError('暂时不支持iOS和安卓以外设备');
  //   }
  //   String fullPath = path.path + '/data.json';
  //   print(fullPath);
  //   return fullPath;
  // }

  void dispose() {
    _database.close();
    _database = null;
  }
}
