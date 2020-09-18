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

class IosStyleToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    Text('Succeed')
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
