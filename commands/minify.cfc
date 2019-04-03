component extends="commandbox.system.BaseCommand" aliases="minify" excludeFromHelp=false {

	property name="shell"						inject="shell";


	/**
	 *
	 **/
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
		
			var settingSting	 = parseForSettings(confPath);

			if (settingSting eq "")
				continue;
			
			var settingArray	= deserializeJSON(settingSting);
			if(!isArray(settingArray)){
				print.whiteOnRedLine( 'Setting struct must be an array of structs' ).toConsole();
				continue;
			}

			for (var aSetting in settingArray){
				var fileArrayName = "";
				// find list of files which have to be an array
				for (var oneKey in aSetting){
					if(isArray(aSetting[oneKey])){
						fileArrayName = oneKey;
						break;
					}
				}
				// js files
				var fileArray 		= aSetting[fileArrayName];
				cnt++;
				
				var inputPath 		= currentDirectory & aSetting['sourceDirectory'];
				fileArray			= buildFileList( inputPath, fileArray );
				
				var destination 	= currentDirectory&aSetting['destinationDirectory'];
				validateDestination(destination,progressBarGeneric);
				
				switch (expression) {
					case "js":
						var fName 					= jscomplier.compile(fileArray,destination,aSetting['name']);
						var updatedSettingString	= rereplace(settingSting,'"minified"[ ]*:[ ]*"[^"]*"','"minified":"#fName#"');
						fileWrite(confPath,replace(fileRead(confPath),settingSting,updatedSettingString));
						break;
						
					case "css":
						cssCompressor.add( fileArray );
						var fName 					= csscompressor.compress( aSetting['name'], destination );

						var updatedSettingString	= rereplace(settingSting,'"minified"[ ]*:[ ]*"[^"]*"','"minified":"#fName#"');
						fileWrite(confPath,replace(fileRead(confPath),settingSting,updatedSettingString));						
						break;
				}
			}

		}

		systemOutput( 'ModuleConfig.cfc or Theme.cfc files checked: #arrayLen(allConfigs)#. Files parsed: #cnt#', 1 );

	}

	/**
	 *
	 **/	
	void function validateDestination(string destination, progressBarGeneric) {
		if ( !directoryExists(destination) ) {
			print.whiteOnRedLine( 'Destination directory: #destination# is not valid' ).toConsole();
			progressBarGeneric.clear();
			abort;
		}		
	}

	/**
	 *
	 **/
	string function parseForSettings(string confPath) {
		var fileString 		= FileRead(confPath);
		var setting 	  	= REMatch('this\.minify[ ]*=[^;]+\];', fileString );

		// make sure it is valid json, create a struct
		if( arrayLen(setting) && setting[1] neq '' ){
			var settingNS 		= Replace(setting[1], '];', ']');
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
