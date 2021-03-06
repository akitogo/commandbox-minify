/**
 * Call this (if you want to use it with Coldbox)
 * {code:bash}
 * minify
 * {bash}
 * .
 * from your project root directory. It will scan for all `Theme.cfc` and `ModuleConfig.cfc` files and see if they contain `this.minify = { "nameItAsYouLike" :  {}, "nameItAsYouLike2" :  {} }`
 * .
 * Make sure that `this.minify` is a valid json. Currently a regex is used to find and parse it.
 * .
 * .
 * {code:js}
 *	this.minify = {
 *	"nameItAsYouLike" :  { 'files':  [
 *	   ,"theme/includes/js/jquery.functions.js"
 *	   ,"theme/includes/js/jquery.fileupload.js"
 *	   ,"theme/includes/js/jquery.scripts.js"
 *  ],
 *  	 "type": "js"
 * 		,"name": "jsall"
 *		,"minified":"willBeFilledAutomatically"
 *		,"sourceDirectory": "this is your base dir starting from project root. Enter e.g. modules here"
 *		,"destinationDirectory": "modules/theme/includes/js"
 *		,"optimization": "none"
 * }
 *  ,
 *  "nameItAsYouLikeN" : { 'files': [
 *		 "bootstrap41/css/bootstrap.min.css"
 *		,"css/custom.css"
 *		,"css/bootstrap-datepicker.css"
 *	],
 *		"type": "css"
 *	 	,"name": "cssall"
 *		,"minified":"willBeFilledAutomatically"
 *		,"sourceDirectory": "modules/theme/includes"
 *		,"destinationDirectory": "modules/theme/includes/css"
 *	}
 *  	};
 * {code}
 */
component extends="commandbox.system.BaseCommand" aliases="minify" excludeFromHelp=false {

	/**
	 *
	 */
	function run() {
		var progressBarGeneric	 = getInstance( "progressBarGeneric" );
		var jscomplier			 = getInstance( "js@commandbox-minify" );
		var cssCompressor		 = getInstance( "cssCompressor@commandbox-minify" );

		var currentDirectory 	= shell.pwd();
		var allConfigs 			= directoryList(path = currentDirectory, recurse=true, listInfo = 'path', filter='ModuleConfig.cfc|Theme.cfc');

		var cnt = 0;
		var pgr = 0;

		//print.Line( 'Checking configs' ).toConsole();
		progressBarGeneric.update( percent=0 );

		for (var confPath in allConfigs){
			pgr++;
			//print.Line( 'Read '&confPath ).toConsole();
			progressBarGeneric.update( percent=pgr*100/arrayLen(allConfigs), currentCount=pgr, totalCount=arrayLen(allConfigs) );
		
			var settingString	 = parseForSettings(confPath);

			if (settingString eq "")
				continue;
			
			var settingStruct	= deserializeJSON(settingString);
			if(!isStruct(settingStruct)){
				print.whiteOnRedLine( 'Setting struct is not a struct #confPath#' ).toConsole();
				continue;
			}

			for (var keyname in settingStruct){
				var aSetting 		= settingStruct[keyname];
				
				// js files
				var fileArray 		= settingStruct[keyname].files;
				cnt++;
				
				var inputPath 		= currentDirectory & aSetting['sourceDirectory'];
				fileArray			= buildFileList( inputPath, fileArray );
				
				var destination 	= currentDirectory&aSetting['destinationDirectory'];

				validateDestination(destination,progressBarGeneric);
				
				switch (aSetting['type']) {
					case "js":
					var fileNameOfCompressed	= jscomplier.compile(fileArray,destination,aSetting['name']);
					break;
					
					case "css":
					cssCompressor.add( fileArray );
					var fileNameOfCompressed	= csscompressor.compress( aSetting['name'], destination );
					break;
					
					default:
					throw('type must be either CSS or JS in #confpath#');
					break;
				}
				updateSettingString(confPath,keyname,settingString,fileNameOfCompressed);
			}
				
		}
			
		print.greenLine( 'ModuleConfig.cfc or Theme.cfc files checked: #arrayLen(allConfigs)#. Settings parsed: #cnt#' );
			
	}
	
	/**
	 * updates ModuleConfig or theme file
	 **/	
		void function updateSettingString(string confpath,string name, string settingString, string fileNameOfCompressed) {
		// find all struct in json array
		// {[],[]}
		var singleJsonStructs	= refind('"[a-zA-Z]+"[ ]*:[^}]+\}',settingString,1,true,'all');
		for (var el in singleJsonStructs){
			if(find('"#arguments.name#"',el.match[1])){
				var changed = rereplace(el.match[1],'"minified"[ ]*:[ ]*"[^"]*"','"minified":"#fileNameOfCompressed#"');
				fileWrite(confPath,replace(fileRead(confPath),el.match[1],changed));
				return;
			}
		}
		print.whiteOnRedLine( 'Could not find and replace #arguments.name# in #confPath#' ).toConsole();


	}
	/**
	 *
	 **/	
	void function validateDestination(string destination, progressBarGeneric) {
		if ( !directoryExists(destination) ) {
			progressBarGeneric.clear();
			error( 'Destination directory: #destination# is not valid' );
		}		
	}

	/**
	 *
	 **/
	string function parseForSettings(string confPath) {
		var fileString 		= FileRead(confPath);
		var setting 	  	= REMatch('this\.minify[ ]*=[^;]+\};', fileString );

		// make sure it is valid json, create a struct
		if( arrayLen(setting) && setting[1] neq '' ){
			var settingNS 		= Replace(setting[1], '};', '}');
			settingNS 			= reReplaceNoCase(settingNS, 'this\.minify[ ]*=', '');
			if(!isJson(settingNS)){
				print.Line( confPath&' contains config, but is not valid Json' ).toConsole();
				return "";
			}
			return settingNS;
		} else {
			return "";
		}		 
	 }
	/**
	 *
	 **/

	array function buildFileList(inputPath,jsFiles) {
		var ac = 1; 
		for (var jsFile in jsFiles){
			//if(!listLen( jsFile, '\/' ))
			jsFiles[ac] = fileSystemUtil.resolvePath( jsFile, inputPath );

			// print.Line( jsFile ).toConsole();
			ac++;
		}

		return jsFiles;	
	}	
}
