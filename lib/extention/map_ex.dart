import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Created by fgyong on 2020/9/17.
///
extension M on Map {
  void setKeyAndValue(String key, String value) {
    this['\"$key\"'] = '\"$value\"';
  }
}
