// Auto-generated from appointment_form.html.
// DO NOT EDIT.

library appointment_form;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/observe/observable.dart' as __observe;
import '_from_packages/widget/components/accordion.dart';
import '_from_packages/widget/components/collapse.dart';
import 'package:web_ui/web_ui.dart';



class AppointmentForm extends WebComponent {
  /** Autogenerated from the template. */

  /** CSS class constants. */
  static Map<String, String> _css = {};

  /** This field is deprecated, use getShadowRoot instead. */
  get _root => getShadowRoot("x-appointment-form");
  static final __shadowTemplate = new autogenerated.DocumentFragment.html('''
        <div is="x-accordion" class="tag_spalte">
          <div is="x-collapse">
            <div class="accordion-heading">
             <a class="accordion-toggle" data-toggle="collapse">Item 1</a>
            </div>
            <input type="text" placeholder="Name">
            <input type="text" placeholder="Nummer">
          </div>
        </div>
      ''');
  autogenerated.DivElement __e0, __e1;
  autogenerated.Template __t;

  void created_autogenerated() {
    var __root = createShadowRoot("x-appointment-form");
    __t = new autogenerated.Template(__root);
    __root.nodes.add(__shadowTemplate.clone(true));
    __e1 = __root.nodes[1];
    __e0 = __e1.nodes[1];
    __t.component(new Collapse()..host = __e0);
    __t.component(new Accordion()..host = __e1);
    __t.create();
  }

  void inserted_autogenerated() {
    __t.insert();
  }

  void removed_autogenerated() {
    __t.remove();
    __t = __e1 = __e0 = null;
  }

  /** Original code from the component. */

  
}
//@ sourceMappingURL=appointment_form.dart.map