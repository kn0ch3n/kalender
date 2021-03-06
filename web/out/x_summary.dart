// Auto-generated from x_summary.html.
// DO NOT EDIT.

library summary;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/observe/observable.dart' as __observe;
import 'dart:html';
import 'package:web_ui/web_ui.dart';
import '_from_packages/widget/components/accordion.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';
import 'kalender_connection.dart';



class XSummary extends WebComponent with Observable  {
  /** Autogenerated from the template. */

  autogenerated.ScopedCssMapper _css;

  /** This field is deprecated, use getShadowRoot instead. */
  get _root => getShadowRoot("x-summary");
  static final __shadowTemplate = new autogenerated.DocumentFragment.html('''
        <textarea rows="1"></textarea>
      ''');
  autogenerated.Template __t;
  autogenerated.TextAreaElement __e21;

  void created_autogenerated() {
    var __root = createShadowRoot("x-summary");
    setScopedCss("x-summary", new autogenerated.ScopedCssMapper({"x-summary":"[is=\"x-summary\"]"}));
    _css = getScopedCss("x-summary");
    __t = new autogenerated.Template(__root);
    __root.nodes.add(__shadowTemplate.clone(true));
    __e21 = __root.nodes[1];
    __t.listen(__e21.onChange, ($event) { valueChanged(); });
    __t.listen(__e21.onInput, ($event) { text = __e21.value; });
    __t.oneWayBind(() => text, (e) { if (__e21.value != e) __e21.value = e; }, false, false);
    __t.create();
  }

  void inserted_autogenerated() {
    __t.insert();
  }

  void removed_autogenerated() {
    __t.remove();
    __t = __e21 = null;
  }

  /** Original code from the component. */

  static List<XSummary> dirtySummaries = new List<XSummary>();
  static KalenderConnection connection;
  
  DateTime time;
  
  Map __$_data;
  Map get _data {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, '_data');
    }
    return __$_data;
  }
  set _data(Map value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, '_data',
          __$_data, value);
    }
    __$_data = value;
  }
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
    //valueChanged();
  }

  valueChanged() {
    dirtySummaries.add(this);
    connection.send('summary', time, _data);
  }
}
//# sourceMappingURL=x_summary.dart.map