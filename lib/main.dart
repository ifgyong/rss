import 'dart:io';
import 'package:overlay_support/overlay_support.dart';
import 'package:rss/route/home/models/HomeViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyhub/flutter_easy_hub.dart';

import 'package:provider/provider.dart';

import 'package:rss/route/home/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      title: '首页',
      theme: ThemeData(
          primarySwatch: Colors.orange,
          indicatorColor: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.orange,
          toggleButtonsTheme: ToggleButtonsThemeData(color: Colors.yellow)),
      home: ChangeNotifierProvider(
        create: (_) => HomeViewModel(),
        builder: (context, child) {
          return MyHomePage(
            title: 'RSS',
          );
        },
      ),
    ));
  }
}
