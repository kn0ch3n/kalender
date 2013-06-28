import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'x_appointment.dart';
import 'x_pause.dart';
import 'dart:json' as JSON;
import 'dart:async';
import 'kalender_connection.dart';

KalenderConnection kalenderConnection;
DivElement termineDiv;


void main() {
  //useShadowDom = true;
  TextAreaElement statusElem = query('#status-area');
  statusArea = new StatusArea(statusElem);
  
  kalenderConnection = new KalenderConnection("ws://127.0.0.1:1337/ws");
  
  setupUI();
}

void setupUI() {
  termineDiv = query("#termine");
  

  for(int i = 1; i <= 31; i++) {
    var id = i.toString().length > 1 ? i.toString() : "0" + i.toString();
    var parent = query("#termine_$id");
    
    for (int h = 8; h <= 17; h++) {
      for (int m = 0; m <= 40; m += 20) {
        if(h == 12 && m == 0) pauseCreator(new DateTime(2013, 6, i, h, m), parent);
        if(h == 12 || h == 13) continue;
        appointmentCreator(new DateTime(2013, 6, i, h, m), parent);
      }
    }
  }

}

void appointmentCreator(DateTime time, var parent){
  var obj = new XAppointment(time, kalenderConnection);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
}

void pauseCreator(DateTime time, var parent){
  var obj = new XPause(time);
  var lifecycleCaller = new ComponentItem(obj)..create();
  parent.children.add(obj.host);
  lifecycleCaller.insert();
}



/*
class Appointment {
  final String time;
  static Map<String, Appointment> _cache;
  String name;
  String number;

  factory Appointment(String name) {
    if (_cache == null) {
      _cache = {};
    }

    if (_cache.containsKey(name)) {
      return _cache[time];
    } else {
      final appointment = new Appointment._internal(name);
      _cache[name] = appointment;
      return appointment;
    }
  }

  Appointment._internal(this.time);
}



class NameInput extends View<InputElement> {
  NameInput(InputElement elem) : super(elem);

  bind() {
    elem.onChange.listen((e) {
      print("Name changed!");
    });
  }

  String get name => elem.value;

}

class NumberInput extends View<InputElement> {
  NumberInput(InputElement elem) : super(elem);

  bind() {
    elem.onChange.listen((e) {
      print("Number changed!");
    });
  }

  String get number => elem.value;
}
*/
