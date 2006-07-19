dojo.debug("extending Editor2Toolbar");
dojo.require("dojo.widget.Editor2");
dojo.require("dojo.widget.Editor2Toolbar");

dojo.lang.extend(dojo.widget.html.Editor2Toolbar, {
  superscriptButton: null,
  superscriptClick: function() { this.exec("superscript"); },
  subscriptButton: null,
  subscriptClick: function() { this.exec("subscript"); },

  symbolButton: null,
  symbolDropDown: null,
  symbolClick: function(e){ 
    var type = 'symbol';
    var h = dojo.render.html;
    this.hideAllDropDowns();
    // FIXME: if we've been "popped out", we need to set the height of the toolbar.
    e.stopPropagation();
    var dd = this[type+"DropDown"];
    var pal = this[type+"Palette"];
    dojo.style.toggleShowing(dd);
    if(!pal){
      pal = this[type+"Palette"] = dojo.widget.createWidget("SymbolPalette", {}, dd, "first");
      var fcp = pal.domNode;
      with(dd.style){
        width = dojo.html.getOuterWidth(fcp) + "px";
        height = dojo.html.getOuterHeight(fcp) + "px";
        zIndex = 1002;
        position = "absolute";
      }

      var cmd = (dojo.render.html.safari) ? "inserttext" : "inserthtml";
      dojo.event.connect(	"after",
                pal, "onSymbolSelect",
                this, "exec",
                function(mi){ mi.args.unshift(cmd); return mi.proceed(); }
      );

      dojo.event.connect(	"after",
                pal, "onSymbolSelect",
                dojo.style, "toggleShowing",
                this, function(mi){ mi.args.unshift(dd); return mi.proceed(); }
      );

      var cid = this.clickInterceptDiv;
      if(!cid){
        cid = this.clickInterceptDiv = document.createElement("div");
        document.body.appendChild(cid);
        with(cid.style){
          backgroundColor = "transparent";
          top = left = "0px";
          height = width = "100%";
          position = "absolute";
          border = "none";
          display = "none";
          zIndex = 1001;
        }
        dojo.event.connect(cid, "onclick", function(){ cid.style.display = "none"; });
      }
      dojo.event.connect(pal, "onSymbolSelect", function(){ cid.style.display = "none"; });

      dojo.event.kwConnect({
        srcObj:		document.body, 
        srcFunc:	"onclick", 
        targetObj:	this,
        targetFunc:	"hideAllDropDowns",
        once:		true
      });
      document.body.appendChild(dd);
    }
    dojo.style.toggleShowing(this.clickInterceptDiv);
    var pos = dojo.style.abs(this[type+"Button"]);
    dojo.html.placeOnScreenPoint(dd, pos.x, pos.y, 0, false);
    if(pal.bgIframe){
      with(pal.bgIframe.style){
        display = "block";
        left = dd.style.left;
        top = dd.style.top;
        width = dojo.style.getOuterWidth(dd)+"px";
        height = dojo.style.getOuterHeight(dd)+"px";
      }
    }
  },

  hideAllDropDowns: function(){
    this.domNode.style.height = "";
    var node;
    dojo.lang.forEach(dojo.widget.byType("Editor2Toolbar"), function(tb){
      try{
        if(node = tb.forecolorDropDown) dojo.style.hide(node);
        if(node = tb.hilitecolorDropDown) dojo.style.hide(node);
        if(node = tb.symbolDropDown) dojo.style.hide(node);
        if(node = tb.styleDropdownContainer) dojo.style.hide(node);
        if(node = tb.clickInterceptDiv) dojo.style.hide(node);
      }catch(e){}
      if(dojo.render.html.ie){
        try{
          dojo.style.hide(tb.forecolorPalette.bgIframe);
        }catch(e){}
        try{
          dojo.style.hide(tb.hilitecolorPalette.bgIframe);
        }catch(e){}
        try{
          dojo.style.hide(tb.symbolPalette.bgIframe);
        }catch(e){}
      }
    });
  }
});


dojo.lang.extend(dojo.widget.html.Editor2, {
  currentSelection: null,
  editorOnLoad: function(){
    var toolbars = dojo.widget.byType("Editor2Toolbar");
    if((!toolbars.length)||(!this.shareToolbar)){
      var tbOpts = {};
      tbOpts.templatePath = dojo.uri.dojoUri("src/widget/templates/HtmlEditorToolbarOneline.html");
      this.toolbarWidget = dojo.widget.createWidget("Editor2Toolbar", 
                  tbOpts, this.domNode, "before");
      dojo.event.connect(this, "destroy", this.toolbarWidget, "destroy");
      this.toolbarWidget.hideUnusableButtons(this);

      if(this.object){
        this.tbBgIframe = new dojo.html.BackgroundIframe(this.toolbarWidget.domNode);
        this.tbBgIframe.iframe.style.height = "30px";
      }

    }else{
      // FIXME: 	should we try harder to explicitly manage focus in
      // 			order to prevent too many editors from all querying
      // 			for button status concurrently?
      // FIXME: 	selecting in one shared toolbar doesn't clobber
      // 			selection in the others. This is problematic.
      this.toolbarWidget = toolbars[0];
      this.toolbarWidget.hideUnusableButtons(this);
    }
    var src = document["documentElement"]||window;
    this.scrollInterval = setInterval(dojo.lang.hitch(this, "globalOnScrollHandler"), 100);
    // dojo.event.connect(src, "onscroll", this, "globalOnScrollHandler");
    dojo.event.connect("before", this, "destroyRendering", this, "unhookScroller");

    // firefox does not let us attach events to an iframe retrieved using 
    // getElementById. For Details see 
    // http://www.digitalmediaminute.com/article/1706/firefoxjavascript-challenge
    // therefore we cannot defer setting up the handlers to when the iframe is
    // loaded. Safari on the other hand does not like onFocus/onBlur for 
    // this.editNode (which is at this point undefined). We need to defer 
    // setting up the handlers, otherwise an OS-Level Application-Switch is 
    // needed to trigger onBlur/onFocus..
    // also, it appears that onFocus/onBlur is actually non-standard behavior 
    // for this.editNode, which is a <body> - only form-elements are supposed
    // to trigger onFocus-Events. In a couple of years, when support improves,
    // we should use onDOMFocusIn and onDOMFocusOut. In the meantime, we work 
    // around this with onMouseDown
    if(dojo.render.html.safari) {
      dojo.event.connect("after", this, "onLoad", dojo.lang.hitch(this, function() { 
        dojo.event.topic.registerPublisher("Editor2.clobberFocus", this.editNode, "onmousedown");
        dojo.event.topic.subscribe("Editor2.clobberFocus", this, "setBlur");
        dojo.event.connect(this.editNode, "onmousedown", this, "setFocus");

        // store selection for later
        dojo.event.browser.addListener(this.editNode, "mouseup", 
          dojo.lang.hitch(this, function() { 
            var sel = this.window.getSelection();
            this.currentSelection = {
              baseNode:     sel.baseNode,
              baseOffset:   sel.baseOffset,
              extentNode:   sel.extentNode,
              extentOffset: sel.extentOffset
            }
        }));
      }));
    } else {
      dojo.event.topic.registerPublisher("Editor2.clobberFocus", this.editNode, "onfocus");
      dojo.event.topic.subscribe("Editor2.clobberFocus", this, "setBlur");
      dojo.event.connect(this.editNode, "onfocus", this, "setFocus");
    } 
    var node;
    if(node = this.toolbarWidget.linkButton) {
      dojo.event.connect(node, "onclick", 
        dojo.lang.hitch(this, function(){
          var range;
          if(this.document.selection){
            range = this.document.selection.createRange().text;
          }else if(dojo.render.html.mozilla){
            range = this.window.getSelection().toString();
          }
          if(range.length){
            this.toolbarWidget.exec("createlink", 
              prompt("Please enter the URL of the link:", "http://"));
          }else{
            alert("Please select text to link");
          }
        })
      );
    }

    var focusFunc = dojo.lang.hitch(this, function(){ 
      if(dojo.render.html.ie){
        this.editNode.focus();
      }else{
        this.window.focus(); 
      }
    });

    dojo.event.connect(this.toolbarWidget, "formatSelectClick", focusFunc);
    dojo.event.connect(this, "execCommand", focusFunc);

    if(this.htmlEditing){
      var tb = this.toolbarWidget.htmltoggleButton;
      if(tb){
        tb.style.display = "";
        dojo.event.connect(this.toolbarWidget, "htmltoggleClick",
                  this, "toggleHtmlEditing");
      }
    }
  }
});
