component  {

    function init() {
        return this;
    }


    /**
     * compile
     */
    function compile( array jsFiles, string destination, string name, string optimization = 'none' ) {
        var compiler        = getCompiler();
        var compilerOptions = getCompilerOptions();

		// can set this true for debug
		CompilerOptions.setPrettyPrint( javaCast( "boolean", false ) );

        if( optimization neq "none" )
            getAdvancedOptimizations( optimization, CompilerOptions );

        var externs = [];

        var	result = compiler.compile(
                externs,
                getInputArray(jsFiles),
                CompilerOptions
        );

        FileWrite( expandPath( destination&"/#name#.js" ), compiler.toSource() );            
    }

    /**
     * getAdvancedOptimizations
     */
	function getAdvancedOptimizations(string optimization, CompilerOptions) {
        switch( optimization ) {
            case "WHITESPACE_ONLY":
                return createObject( "java", "com.google.javascript.jscomp.CompilationLevel", getcompilerJarPath() )
                .WHITESPACE_ONLY.setOptionsForCompilationLevel( CompilerOptions );

            case "SIMPLE_OPTIMIZATIONS":
                return createObject( "java", "com.google.javascript.jscomp.CompilationLevel", getcompilerJarPath() )
                .SIMPLE_OPTIMIZATIONS.setOptionsForCompilationLevel( CompilerOptions );
            
            case "ADVANCED_OPTIMIZATIONS":
                return  createObject( "java", "com.google.javascript.jscomp.CompilationLevel", getcompilerJarPath() )
                .ADVANCED_OPTIMIZATIONS.setOptionsForCompilationLevel( CompilerOptions );
        }
    }

    /**
     * getInputArray
     */  
	function getInputArray(array jsfiles) {    
        var input = [];

        for (var jsFile in jsfiles) {

            var tmpInput = createObject( "java", "com.google.javascript.jscomp.SourceFile", getcompilerJarPath() ).fromCode(
                javaCast( "string", getFileFromPath( jsFile ) ),
                javaCast( "string", fileRead( jsFile ) )
            );

            arrayAppend(input,tmpInput);
        }
        return input;
    }

    /**
     * returns javascript.jscomp.Compiler
     */    
	function getCompiler() {
		return createObject( "java", "com.google.javascript.jscomp.Compiler", getcompilerJarPath() ).init();
    }

    /**
     * returns javascript.jscomp.CompilerOptions
     */    
	function getCompilerOptions() {     
        return createObject( "java", "com.google.javascript.jscomp.CompilerOptions", getcompilerJarPath() ).init();
    }

    /**
     * returns jar pathj from lib directory
     */
    private function getcompilerJarPath() {  
		// find jar path
		var path		=   getDirectoryFromPath( getCurrentTemplatePath() );

        return expandpath(path&'../lib/closure-compiler.jar');
    }           


}
