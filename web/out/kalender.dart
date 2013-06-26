// Auto-generated from kalender.html.
// DO NOT EDIT.

library kalender_html;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/observe/observable.dart' as __observe;
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'x_appointment.dart';
import 'x_pause.dart';


// Original code


DivElement termineDiv;

void main() {
  //useShadowDom = true;
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
  var obj = new XAppointment(time);
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

abstract class View<T> {
  final T elem;

  View(this.elem) {
    bind();
  }

  // bind to event listeners
  void bind() { }
}

class NameInput extends View<InputElement> {
  NameInput(InputElement elem) : super(elem);

  bind() {
    elem.onChange.listen((e) {
      //TODO: idk...
    });
  }

  String get name => elem.value;

}

class NumberInput extends View<InputElement> {
  NumberInput(InputElement elem) : super(elem);

  bind() {
    elem.onChange.listen((e) {
      //TODO: idk...
    });
  }

  String get number => elem.value;
}

// Additional generated code
void init_autogenerated() {
  var __root = autogenerated.document.body;
  var __t = new autogenerated.Template(__root);
  __t.create();
  __t.insert();
}

//# sourceMappingURL=kalender.dart.map