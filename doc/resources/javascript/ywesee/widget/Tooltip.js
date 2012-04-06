require([
    'dojo/_base/declare',
    'dojo/_base/connect',
    'dojo/_base/lang',
    'dojox/widget/DynamicTooltip', // new xhr support tooltip
    'dijit/layout/ContentPane'
  ], function(declare, connect, lang, tooltip, contentPane) {
  declare('ywesee.widget.Tooltip', [tooltip], {
    href:        null,
    contentPane: null,
    _hoverContent: false,
    _contentNode:  null,
    _handle1:      null,
    _handle2:      null,
    _handle3:      null,
    _handle4:      null,
    _hideTimer:    null,

    constructor: function(args) {
      declare.safeMixin(this, args);
    },

    open: function() {
      if (!master) {
        var master = new dijit._MasterTooltip();
      }
      this._contentNode = master.domNode;
      if (this.href && (!this.contentPane)) {
        domNode = document.createElement("div");
        this.contentPane = new dijit.layout.ContentPane({
          href:    this.href,
          placeAt: this._contentNode.getAttribute('id')
        }, domNode);
        this.contentPane.startup();
      }
      this._handle1 = connect.connect(this._contentNode, 'onmouseover',this, 'onHoverContent');
      this._handle2 = connect.connect(this._contentNode, 'onhover', this, 'onHoverContent');
      this._handle3 = connect.connect(this._contentNode, 'onmouseout', this, 'onUnHoverContent');
      this._handle4 = connect.connect(this._contentNode, 'onunhover', this, 'onUnHoverContent');
      this.inherited("open", arguments);
    },

    close: function() {
      connect.disconnect(this._handle1);
      connect.disconnect(this._handle2);
      connect.disconnect(this._handle3);
      connect.disconnect(this._handle4);
      this.inherited("close", arguments);
    },

    onHoverContent: function(/*Event*/ e) {
      this._hoverContent = true;
    },

    onUnHoverContent: function(/*Event*/ e) {
      if (dojo.isDescendant(e.relatedTarget, this._contentNode)){
        // false event; just moved from target to target child; ignore.
        return;
      }
      this._hoverContent = false;
      this._onUnHover(e);
    },

    _onUnHover: function(/*Event*/ e) {
      this._hideTimer = setTimeout(lang.hitch(this, "_deferredOnUnHover", arguments), 2000);
    },

    _deferredOnUnHover: function(/*Event*/ e) {
      if (this._hoverContent) { return; }
      if (this._showTimer) {
        clearTimeout(this._showTimer);
        delete this._showTimer;
      } else {
        this.close();
      }
    }
  });
});

