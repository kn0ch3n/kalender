library pause;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

class XPause extends WebComponent {
  
  static Map<DateTime, XPause> _cache;
  
  DateTime _time;
  String get heading => timeForHeading(_time);
  String name;
  String text;

  factory XPause(DateTime time) {
    if (_cache == null) {
      _cache = new Map();
    }

    if (_cache.containsKey(time)) {
      return _cache[time];
    } else {
      final pause = new XPause._internal(time);
      _cache[time] = pause;
      return pause;
    }
  }

  XPause._internal(DateTime time) {
    host = (new Element.html('<x-pause time="$time"></x-pause>'));
    this._time = time;
  }
  
  String timeForHeading(DateTime t) {
    String hour = t.hour.toString();
    String minute = t.minute.toString();
    hour = hour.length > 1 ? hour : "0" + hour;
    minute = minute.length > 1 ? minute : "0" + minute;
    
    return hour + ":" + minute;
  }

  printChanged() {
    print("Name of $_time changed to: $name");
  }
}