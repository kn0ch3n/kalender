// Auto-generated from collapse.html.
// DO NOT EDIT.

library x_collapse;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/observe/observable.dart' as __observe;
import 'dart:async';
import 'dart:html';
import 'package:bot/bot.dart';
import 'package:web_ui/web_ui.dart';
import 'package:widget/effects.dart';
import 'package:widget/widget.dart';



/**
 * [Collapse] uses a content model similar to [collapse functionality](http://twitter.github.com/bootstrap/javascript.html#collapse) in Bootstrap.
 *
 * The header element for [Collapse] is a child element with class `accordion-heading`.
 *
 * The rest of the children are rendered as content.
 *
 * [Collapse] listens for `click` events and toggles visibility of content if the
 * click target has attribute `data-toggle="collapse"`.
 */
class Collapse extends WebComponent implements ShowHideComponent {
  /** Autogenerated from the template. */

  autogenerated.ScopedCssMapper _css;

  /** This field is deprecated, use getShadowRoot instead. */
  get _root => getShadowRoot("x-collapse");
  static final __shadowTemplate = new autogenerated.DocumentFragment.html('''
        <div class="accordion-group">
          <content select=".accordion-heading"></content>
          <div class="collapse-body-x">
            <div class="accordion-inner">
              <content></content>
            </div>
          </div>
        </div>
      ''');
  autogenerated.Template __t;

  void created_autogenerated() {
    var __root = createShadowRoot("x-collapse");
    setScopedCss("x-collapse", new autogenerated.ScopedCssMapper({"x-collapse":"[is=\"x-collapse\"]"}));
    _css = getScopedCss("x-collapse");
    __t = new autogenerated.Template(__root);
    __root.nodes.add(__shadowTemplate.clone(true));
    __t.create();
  }

  void inserted_autogenerated() {
    __t.insert();
  }

  void removed_autogenerated() {
    __t.remove();
    __t = null;
  }

  /** Original code from the component. */

  static const String _collapseDivSelector = '.collapse-body-x';
  static final ShowHideEffect _effect = new ShrinkEffect();

  bool _isShown = true;

  bool get isShown => _isShown;

  void set isShown(bool value) {
    assert(value != null);
    if(value != _isShown) {
      _isShown = value;
      _updateElements();

      ShowHideComponent.dispatchToggleEvent(this);
    }
  }

  Stream<Event> get onToggle => ShowHideComponent.toggleEvent.forTarget(this);

  void hide() {
    isShown = false;
  }

  void show() {
    isShown = true;
  }

  void toggle() {
    isShown = !isShown;
  }

  @protected
  void created() {
    this.onClick.listen(_onClick);
  }

  @protected
  void inserted() {
    _updateElements(true);
  }

  void _onClick(MouseEvent e) {
    if(!e.defaultPrevented) {
      final clickElement = e.target as Element;

      if(clickElement != null && clickElement.dataset['toggle'] == 'collapse') {
        toggle();
        e.preventDefault();
      }
    }
  }

  void _updateElements([bool skipAnimation = false]) {
    final collapseDiv = this.query(_collapseDivSelector);
    if(collapseDiv != null) {
      final action = _isShown ? ShowHideAction.SHOW : ShowHideAction.HIDE;
      final effect = skipAnimation ? null : _effect;
      ShowHide.begin(action, collapseDiv, effect: effect);
    }
  }
}

//# sourceMappingURL=collapse.dart.map