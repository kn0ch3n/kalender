library summary;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';
import 'kalender_connection.dart';

class XSummary extends WebComponent {
  static List<XSummary> dirtySummaries = new List<XSummary>();
  static KalenderConnection connection;
  DateTime time;
  @observable Map _data;
  String get text => _data['text'];
  set text(value) => _data['text'] = value;
  
  XSummary(DateTime time) {
    host = (new Element.html('<x-summary></x-summary>'));
    this.time = time;
    _data = toObservable({
      'text': null
    });
  }
  
  clear() {
    _data = toObservable({
      'text': null
    });
  }

  valueChanged() {
    dirtySummaries.add(this);
    connection.send(time, _data);
  }
}