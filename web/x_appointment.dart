library appointment;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';
import 'kalender_connection.dart';

class XAppointment extends WebComponent {
  static List<XAppointment> dirtyAppointments = new List<XAppointment>();
  static KalenderConnection connection;
  String id;
  
  final List<String> types = ["Frei", "Werkstatt", "Nicht im Haus", "Einlagen", "Einlagen Folge"];
  final List<String> typeImages = ["img/frei.png", "img/werkstatt.png", "img/nicht_im_haus.png", "img/einlagen.png", "img/einlagen_folge.png"];

  DateTime time;
  String get heading => timeForHeading(time);
  String get headingWithDate => timeAndDateForHeading(time);

  @observable Map _data;
  String get name => _data['name'];
  set name(value) => _data['name'] = value;
  String get number => _data['number'];
  set number(value) => _data['number'] = value;
  int get type => _data['type'];
  set type(value) => _data['type'] = value;
  
  XAppointment(DateTime time, String id) {
    host = new Element.html('<x-appointment id="$id"></x-appointment>');
    this.time = time;
    this._data = toObservable({
      'name': null,
      'number': null,
      'type': 0
    });
    //print("XAppointment created: ${time.toString()}, ID: $id");
  }

  clear() {
    _data = toObservable({
      'name': null,
      'number': null,
      'type': 0
    });
    //print("XAppointment cleared: " + time.toString());
  }
  
  String timeForHeading(DateTime t) {
    String hour = t.hour.toString();
    String minute = t.minute.toString();
    hour = hour.length > 1 ? hour : "0" + hour;
    minute = minute.length > 1 ? minute : "0" + minute;
    
    return hour + ":" + minute;
  }

  timeAndDateForHeading(DateTime t) {
    String day = t.day.toString();
    String month = t.month.toString();
    String year = t.year.toString();
    
    return "${day}.${month}.${year}, ${timeForHeading(t)}";
  }
  
  valueChanged() {
    print("in valueChanged of XAppointment");
    dirtyAppointments.add(this);
    print("after adding, dirtyAppointments length is ${dirtyAppointments.length}");
    connection.send(time, _data);
    statusArea.displaySaveMessage(headingWithDate, _data);
  }
  
  toggleImage() {
    type++;
    if (type >= types.length) type = 0;
    valueChanged();
  }
}