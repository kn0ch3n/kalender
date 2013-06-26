library appointment;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';

class XAppointment extends WebComponent {
  
  static Map<DateTime, XAppointment> _cache;
  
  DateTime _time;
  String get heading => timeForHeading(_time);
  String name;
  String number;

  factory XAppointment(DateTime time) {
    if (_cache == null) {
      _cache = new Map();
    }

    if (_cache.containsKey(time)) {
      return _cache[time];
    } else {
      final appointment = new XAppointment._internal(time);
      _cache[time] = appointment;
      return appointment;
    }
  }

  XAppointment._internal(DateTime time) {
    host = (new Element.html('<x-appointment time="$time"></x-appointment>'));
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
    print("Name changed to: " + name);
  }
}