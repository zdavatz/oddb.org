dojo.provide("ywesee.widget.Tooltip");

dojo.require("dijit.Tooltip");
dojo.require("dijit.layout.ContentPane");

dojo.declare(
  "ywesee.widget.Tooltip",    
  [dijit.Tooltip],
  {
    href: null,
    contentPane: null,
    _contentNode: null,
    _hoverContent: false,
    _handle1: null,
    _handle2: null,
    _handle3: null,
    _handle4: null,
    _hideTimer: null,

    open: function(){
      //if(this.isShowingNow) { return; }

      if(!dijit._masterTT){
        dijit._masterTT=new dijit._MasterTooltip();
      }

      this._contentNode = dijit._masterTT.domNode;
      if(this.href && (!this.contentPane)) {
        this.domNode = document.createElement("div");
        this.contentPane = new dijit.layout.ContentPane({href:this.href}, this.domNode);
        this.connect(this.contentPane, 'onLoad', 'onLoad');
        this.contentPane.startup();
      }
      this._handle1 = dojo.connect(this._contentNode, 'onmouseover', this, 'onHoverContent');
      this._handle2 = dojo.connect(this._contentNode, 'onhover', this, 'onHoverContent');
      this._handle3 = dojo.connect(this._contentNode, 'onmouseout', this, 'onUnHoverContent');
      this._handle4 = dojo.connect(this._contentNode, 'onunhover', this, 'onUnHoverContent');
      this.inherited("open", arguments);
    },

    close: function(){
      dojo.disconnect(this._handle1);
      dojo.disconnect(this._handle2);
      dojo.disconnect(this._handle3);
      dojo.disconnect(this._handle4);
      this.inherited("close", arguments);
    },

    onLoad: function(){
      //if(this.isShowingNow){
        this.close();
        this.open();
      //}
    },

    onHoverContent: function(/*Event*/ e){
      this._hoverContent = true;
    },

    onUnHoverContent: function(/*Event*/ e){
			if(dojo.isDescendant(e.relatedTarget, this._contentNode)){
				// false event; just moved from target to target child; ignore.
				return;
			}
      this._hoverContent = false;
      this._onUnHover(e);
    },

    _onUnHover: function(/*Event*/ e){
      if(this._hoverContent) { return; }
      this._hideTimer = setTimeout(dojo.hitch(this, "_deferredOnUnHover", arguments), 100);
    },

    _deferredOnUnHover: function(/*Event*/ e){
      if(this._hoverContent) { return; }

			if(this._showTimer){
				clearTimeout(this._showTimer);
				delete this._showTimer;
			}else{
				this.close();
			}
    }
  }
);
