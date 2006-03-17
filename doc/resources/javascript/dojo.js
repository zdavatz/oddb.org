(function(){
	var hostEnv = "browser";
	var isRhino = false;
	var isSpidermonkey = false;
	var isDashboard = false;
	if((typeof this["load"] == "function")&&(typeof this["Packages"] == "function")){
		var isRhino = true;
		hostEnv = "rhino";
	}else if(typeof this["load"] == "function"){
		isSpidermonkey  = true;
		hostEnv = "spidermonkey";
	}else if(window.widget){
		isDashboard = true;
		hostEnv = "dashboard";
	}
	var tmps = ["bootstrap1.js", "hostenv_"+hostEnv+".js", "bootstrap2.js"];

	if(hostEnv == "dashboard"){
		tmps.splice(1, 0, "hostenv_browser.js");
	}

	if( (this["djConfig"])&&(djConfig["baseScriptUri"]) ){
		var root = djConfig["baseScriptUri"];
	}else if((this["djConfig"])&&(djConfig["baseRelativePath"])){
		var root = djConfig["baseRelativePath"];
	}else{
		var root = "./";
		if(!this["djConfig"]){
			djConfig = { baseRelativePath: "./" };
		}

		// attempt to figure out the path to dojo if it isn't set in the config
		if((this["document"])&&(this["document"]["getElementsByTagName"])){
			var scripts = document.getElementsByTagName("script");
			var rePkg = /(__package__|dojo)\.js([\?\.]|$)/i;
			for(var i = 0; i < scripts.length; i++) {
				var src = scripts[i].getAttribute("src");
				if(!src) { continue; }
				var m = src.match(rePkg);
				if(m) {
					root = src.substring(0, m.index);
					if(!this["djConfig"]) { djConfig = {}; }
					djConfig["baseScriptUri"] = djConfig["baseRelativePath"] = root;
					break;
				}
			}
		}
	}

	if((this["djConfig"])&&(djConfig["debugAtAllCosts"])&&(!isRhino)&&(!isDashboard)){
		tmps.push("browser_debug.js");
	}

	for(var x in tmps){
		var spath = root+"src/"+tmps[x];
		if(isRhino||isSpidermonkey){
			load(spath);
		} else {
			try {
				document.write("<scr"+"ipt type='text/javascript' src='"+spath+"'></scr"+"ipt>");
			} catch (e) {
				var script = document.createElement("script");
				script.src = spath;
				document.getElementsByTagName("head")[0].appendChild(script);
			}
		}
	}
})();
