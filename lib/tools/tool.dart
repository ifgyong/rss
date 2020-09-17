import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by fgyong on 2020/9/16.
///

class F {
  static dynamic valueForKey(Map map, dynamic key) {
    if (map.containsKey(key)) {
      if (map[key] != null) {
        return map[key];
      }
    }
    return null;
  }
}

class Bus {
  static EventBus _bus;
  factory Bus() => Bus._instanceBus();
  Bus._instanceBus() {
    if (_bus == null) {
      _bus = EventBus();
    }
  }
}

void printY(Object object) {
  if (kDebugMode) print(object);
}
