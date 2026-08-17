/**
* Compressing and merging files from a location use
* .
* {code:bash}
* minifyjs "/path/to/js/files/*"
* mjs "/path/to/js/files/*"
* {code}
* .
* To minify every file into its own output file instead of one combined file use
* .
* {code:bash}
* minifyjs "/path/to/js/files/*" --!combine
* {code}
* .
*/
component extends="commandbox.system.BaseCommand" aliases="mjs" excludeFromHelp=false {


/**
* @path A file globbing pattern of the js files to minify
* @combine Combine all files into one output file (true, default) or minify every file into its own output file (false)
*/
function run( required Globber path, boolean combine=true )  {
  var jscomplier			  = getInstance( "js@commandbox-minify" );
  var currentDirectory 	= shell.pwd();
  var cnt               = 0;
  var fileArray         = [];
  path.apply( function( thisPath ){
    if (right(thisPath,2) == 'js'){
      fileArray.append(thisPath);
      print.line( 'Adding file ' & thisPath ).toConsole();
      cnt++;
    }
  } );

  if (cnt){
    if (combine){
      var fileNameOfCompressed	= jscomplier.compile(fileArray,currentDirectory,'jsall');
      print.greenline( 'Merged and compressed into file ' & fileNameOfCompressed ).toConsole();
    } else {
      for (var aFile in fileArray){
        var fileNameOfCompressed	= jscomplier.compile([aFile],currentDirectory,reReplace( getFileFromPath( aFile ), '\.[^.]*$', '' ));
        print.greenline( 'Compressed into file ' & fileNameOfCompressed ).toConsole();
      }
    }
  } else {
    error( 'No JS file found ' );
  }


}
}