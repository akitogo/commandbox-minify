component extends="commandbox.system.BaseCommand" aliases="minify" excludeFromHelp=false {

	property name="shell"						inject="shell";
	property name="jscomplier"					inject="js@commandbox-minify";

	/**
	 *
	 **/

	function run() {
		var jscomplier = getInstance("js@commandbox-minify");

		var currentDirectory 	= shell.pwd();
		var allConfigs 			= directoryList(path = currentDirectory, recurse=true, listInfo = 'path', filter='ModuleConfig.cfc|Theme.cfc');

		var cnt = 0;
		print.Line( 'Checking configs' ).toConsole();

		for (var confPath in allConfigs){
			print.Line( 'Read '&confPath ).toConsole();
			
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

			var source 		= '';
			inputPath 		= currentDirectory & settingStruct['sourceDirectory'];
			
			cnt = 1; 
			for (var jsFile in jsFiles){
				//if(!listLen( jsFile, '\/' ))
				jsFiles[cnt] = fileSystemUtil.resolvePath( jsFile, inputPath );

				print.Line( jsFile ).toConsole();
				cnt++;
			}

			var destination 		= '';
			if( find('.',settingStruct['destinationDirectory']) )
				destination		= fileSystemUtil.resolvePath( settingStruct['destinationDirectory'] );
			else
				destination 		= fileSystemUtil.resolvePath( './#settingStruct['destinationDirectory']#' );

			jscomplier.compile(jsFiles,destination,settingStruct['name']);

		}

		systemOutput( 'Files parsed: #cnt#', 1 );

	}

}
