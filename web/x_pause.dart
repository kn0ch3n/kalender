library pause;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';
import 'kalender_connection.dart';

class XPause extends WebComponent {
  static List<XPause> dirtyPauses = new List<XPause>();
  static KalenderConnection connection;
  
  DateTime time;
  String get heading => timeForHeading(time);

  @observable Map _data;
  String get name => _data['name'];
  set name(value) => _data['name'] = value;
  String get text => _data['text'];
  set text(value) => _data['text'] = value;
  
  XPause(DateTime time) {
    host = (new Element.html('<x-pause></x-pause>'));
    this.time = time;
    _data = toObservable({
      'name': null,
      'text': null
    });
  }
  
  String timeForHeading(DateTime t) {
    String hour = t.hour.toString();
    String minute = t.minute.toString();
    hour = hour.length > 1 ? hour : "0" + hour;
    minute = minute.length > 1 ? minute : "0" + minute;
    
    return hour + ":" + minute;
  }

  valueChanged() {
    dirtyPauses.add(this);
    connection.send(time, _data);
  }
}