component extends="commandbox.system.BaseCommand" aliases="minify" excludeFromHelp=false {

	property name="shell"						inject="shell";
	property name="progressBarGeneric" 			inject="progressBarGeneric";

	property name="jscomplier"					inject="js@commandbox-minify";

	/**
	 *
	 **/

	function run() {
		var jscomplier = getInstance("js@commandbox-minify");

		var currentDirectory 	= shell.pwd();
		var allConfigs 			= directoryList(path = currentDirectory, recurse=true, listInfo = 'path', filter='ModuleConfig.cfc|Theme.cfc');

		var cnt = 0;
		//print.Line( 'Checking configs' ).toConsole();
		progressBarGeneric.update( percent=0 );

		for (var confPath in allConfigs){
			//print.Line( 'Read '&confPath ).toConsole();
			progressBarGeneric.update( percent=25, currentCount=cnt*100/arrayLen(allConfigs), totalCount=arrayLen(allConfigs) );
		
			var fileString 		= FileRead(confPath);
			var setting 	  	= REMatch('{[ ]*"jsfiles(.*)};', fileString );

			// make sure it is valid json, create a struct
			if( arrayLen(setting) && setting[1] neq '' ){
				var settingNS 		= Replace(setting[1], '};', '}');
				if(!isJson(settingNS)){
					print.Line( confPath&' contains config, but is not valid Json' ).toConsole();
					continue;
				}
				var settingStruct 	= deserializeJson(settingNS);
				var jsFiles 		= settingStruct['jsfiles'];
				cnt++;
			} else {
				continue;
			}

			var inputPath 		= currentDirectory & settingStruct['sourceDirectory'];
			
			var ac = 1; 
			for (var jsFile in jsFiles){
				//if(!listLen( jsFile, '\/' ))
				jsFiles[ac] = fileSystemUtil.resolvePath( jsFile, inputPath );

				// print.Line( jsFile ).toConsole();
				ac++;
			}

			var destination 		= currentDirectory&settingStruct['destinationDirectory'];
			if ( !directoryExists(destination) ) {
				print.blackOnRedLine( 'Destination directory: #destination# is not valid' ).toConsole();
				progressBarGeneric.clear();
				abort;
			}
			var x = getinstance("adler32@commandbox-minify");

			jscomplier.compile(jsFiles,destination,settingStruct['name']);

		}
		progressBarGeneric.clear();

		systemOutput( 'Files checked: #arrayLen(allConfigs)#. Files parsed: #cnt#', 1 );

	}

}
