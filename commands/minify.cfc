component extends="commandbox.system.BaseCommand" aliases="minify js" excludeFromHelp=false {

	//property name="javaLoader"		inject="loader@cbjavaloader";

	/**
	 * @pain.hint Set to true for maximum chuck information
	 **/
	function run() {

		// find theme path and read settings
		var themePath 		= fileSystemUtil.resolvePath( './modules/contentbox/themes/akitogo/Theme.cfc' );
		var fileString 		= FileRead(themePath);
		var setting 	  	= REMatch('{[ ]*"jsfiles(.*)};', fileString );
		var settingNS 		= '';
		var settingStruct   = '';

		// make sure it is valid json, create a struct
		if( setting[1] neq '' ){
			settingNS = Replace(setting[1], '};', '}');
			settingStruct 	= deserializeJson(settingNS);
		}else{
			systemoutput('Settings not found!');abort;
		}

		// find jar path
		var path		= getDirectoryFromPath( getCurrentTemplatePath() );
		var jarPath 	= expandpath(path&'../lib/closure-compiler.jar');

		var inputPath 		= '';
		if( find('.',settingStruct['entryDirectory']) )
			inputPath		= fileSystemUtil.resolvePath( settingStruct['entryDirectory'] );
		inputPath 		= fileSystemUtil.resolvePath( './#settingStruct['entryDirectory']#' );

		var outputPath 		= '';
		if( find('.',settingStruct['outputDirectory']) )
			outputPath		= fileSystemUtil.resolvePath( settingStruct['outputDirectory'] );
		outputPath 		= fileSystemUtil.resolvePath( './#settingStruct['outputDirectory']#' );

		var Compiler 		= createObject( "java", "com.google.javascript.jscomp.Compiler", jarPath ).init();
		var CompilerOptions = createObject( "java", "com.google.javascript.jscomp.CompilerOptions", jarPath ).init();

		// can set this true for debug
		CompilerOptions.setPrettyPrint( javaCast( "boolean", false ) );

		if( settingStruct['Optimisation'] neq "none" ){
			switch( settingStruct['Optimisation'] ) {
			    case "WHITESPACE_ONLY":
					var AdvancedOptimizations = createObject( "java", "com.google.javascript.jscomp.CompilationLevel", jarPath )
					.WHITESPACE_ONLY.setOptionsForCompilationLevel( CompilerOptions );
			    	break;
			    case "SIMPLE_OPTIMIZATIONS":
					var AdvancedOptimizations = createObject( "java", "com.google.javascript.jscomp.CompilationLevel", jarPath )
					.SIMPLE_OPTIMIZATIONS.setOptionsForCompilationLevel( CompilerOptions );
			        break;
			    case "ADVANCED_OPTIMIZATIONS":
					var AdvancedOptimizations = createObject( "java", "com.google.javascript.jscomp.CompilationLevel", jarPath )
					.ADVANCED_OPTIMIZATIONS.setOptionsForCompilationLevel( CompilerOptions );
			        break;
			    default:
			         // do nothing
			}
		}

		var externs = [];
		var input = [];

		for (i=1;i<=arrayLen(settingStruct['jsfiles']);i++) {
			var inputFile = expandPath(inputPath&"/#settingStruct['jsfiles'][i]#");
			var tmpInput = createObject( "java", "com.google.javascript.jscomp.SourceFile", jarPath ).fromCode(
			javaCast( "string", getFileFromPath( inputFile ) ),
			javaCast( "string", fileRead( inputFile ) ));
			arrayAppend(input,tmpInput);
		}

		var	result = compiler.compile(
			externs,
			input,
			CompilerOptions
		);

		FileWrite( expandPath( outputPath&"/#settingStruct['name']#.js" ), compiler.toSource() );
	}

}
