dojo.provide("ywesee.widget.SymbolPalette");
dojo.provide("ywesee.widget.html.SymbolPalette");
dojo.require("dojo.widget.*");
dojo.require("dojo.widget.Toolbar");
dojo.require("dojo.html");

dojo.widget.tags.addParseTreeHandler("dojo:ToolbarSymbolDialog");

dojo.widget.html.ToolbarSymbolDialog = function(){
	dojo.widget.html.ToolbarDialog.call(this);
}

dojo.inherits(dojo.widget.html.ToolbarSymbolDialog, dojo.widget.html.ToolbarDialog);

dojo.lang.extend(dojo.widget.html.ToolbarSymbolDialog, {

	widgetType: "ToolbarSymbolDialog",

	fillInTemplate: function (args, frag) {
		dojo.widget.html.ToolbarSymbolDialog.superclass.fillInTemplate.call(this, args, frag);
		this.dialog = dojo.widget.createWidget("SymbolPalette");
		this.dialog.domNode.style.position = "absolute";

		dojo.event.connect(this.dialog, "onSymbolSelect", this, "_setValue");
	},

	_setValue: function(symbol) {
    dojo.debug("_setValue("+symbol+")");
		this._value = symbol;
    dojo.debug("firing onSetValue(" + symbol + ")");
		this._fireEvent("onSetValue", symbol);
	},
	
	showDialog: function (e) {
		dojo.widget.html.ToolbarSymbolDialog.superclass.showDialog.call(this, e);
		var x = dojo.html.getAbsoluteX(this.domNode);
		var y = dojo.html.getAbsoluteY(this.domNode) + dojo.html.getInnerHeight(this.domNode);
		this.dialog.showAt(x, y);
	},
	
	hideDialog: function (e) {
		dojo.widget.html.ToolbarSymbolDialog.superclass.hideDialog.call(this, e);
		this.dialog.hide();
	}
});



dojo.widget.tags.addParseTreeHandler("dojo:symbolpalette");

dojo.widget.html.SymbolPalette = function () {
	dojo.widget.HtmlWidget.call(this);
}

dojo.inherits(dojo.widget.html.SymbolPalette, dojo.widget.HtmlWidget);

dojo.lang.extend(dojo.widget.html.SymbolPalette, {

	widgetType: "symbolpalette",
	
	bgIframe: null,
	
  palette: [
    ["plusmn", "times", "divide", "fnof", "minus", "cong", "sim", "le", "ge"],
    ["infin", "prop", "part", "ne", "equiv", "asymp", "empty", "radic"],
    ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota"],
    ["Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma"],
    ["Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega"],
    ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota"],
    ["kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma"],
    ["tau", "upsilon", "phi", "chi", "psi", "omega"]
  ],

	buildRendering: function () {
		
		this.domNode = document.createElement("table");
		dojo.html.disableSelection(this.domNode);
		dojo.event.connect(this.domNode, "onmousedown", function (e) {
			e.preventDefault();
		});
		with (this.domNode.style) { // set the table's properties
			//cellPadding = "0"; cellSpacing = "1"; border = "1";
			backgroundColor = "white"; //style.position = "absolute";
			border = "1px solid gray"; 
		}
		var tbody = document.createElement("tbody");
		this.domNode.appendChild(tbody);
		var symbols = this.palette;
		for (var i = 0; i < symbols.length; i++) {
			var tr = document.createElement("tr");
			for (var j = 0; j < symbols[i].length; j++) {
	
				var td = document.createElement("td");
				with (td.style) {
					border = "1px solid white";
          padding = "0px";
          margin = "1px";
					width = height = "18px";
					fontSize = "14px";
          textAlign = 'center';
				}
	
				td.innerHTML = "&" + symbols[i][j] + ";";
	
				td.onmouseover = function (e) { this.style.borderColor = "gray"; }
				td.onmouseout = function (e) { this.style.borderColor = "white"; }
				dojo.event.connect(td, "onmousedown", this, "click");
	
				tr.appendChild(td);
			}
			tbody.appendChild(tr);
		}

		if(dojo.render.html.ie){
			this.bgIframe = document.createElement("<iframe frameborder='0' src='javascript:void(0);'>");
			with(this.bgIframe.style){
				position = "absolute";
				left = top = "0px";
				display = "none";
			}
			document.body.appendChild(this.bgIframe);
			dojo.style.setOpacity(this.bgIframe, 0);
		}
	},

	click: function (e) {
		this.onSymbolSelect(e.currentTarget.innerHTML);
		e.currentTarget.style.borderColor = "green";
	},

	onSymbolSelect: function (symbol) { 
    dojo.debug("onSymbolSelect("+symbol+")");
  },

	hide: function (){
		this.domNode.parentNode.removeChild(this.domNode);
		if(this.bgIframe){
			this.bgIframe.style.display = "none";
		}
	},
	
	showAt: function (x, y) {
		with(this.domNode.style){
			top = y + "px";
			left = x + "px";
			zIndex = 999;
		}
		document.body.appendChild(this.domNode);
		if(this.bgIframe){
			with(this.bgIframe.style){
				display = "block";
				top = y + "px";
				left = x + "px";
				zIndex = 998;
				width = dojo.html.getOuterWidth(this.domNode) + "px";
				height = dojo.html.getOuterHeight(this.domNode) + "px";
			}

		}
	}

});
