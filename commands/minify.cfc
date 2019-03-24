component extends="commandbox.system.BaseCommand" aliases="minify" excludeFromHelp=false {

	property name="shell"						inject="shell";
	property name="progressBarGeneric" 			inject="progressBarGeneric";	// this is not working with 4.6

	property name="jscomplier"					inject="js@commandbox-minify";	// this is not working with 4.5 and 4.6

	/**
	 *
	 **/

	function run() {
		var progressBarGeneric = getInstance( 'progressBarGeneric' );
		var jscomplier = getInstance("js@commandbox-minify");

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

			jscomplier.compile(jsFiles,destination,settingStruct['name']);

		}

		systemOutput( 'Files checked: #arrayLen(allConfigs)#. Files parsed: #cnt#', 1 );

	}

}
