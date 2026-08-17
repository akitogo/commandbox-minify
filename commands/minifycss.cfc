/**
* Compressing and merging files from a location use
* .
* {code:bash}
* minifycss "/path/to/css/files/*"
* mcss "/path/to/css/files/*"
* {code}
* .
* To minify every file into its own output file instead of one combined file use
* .
* {code:bash}
* minifycss "/path/to/css/files/*" --!combine
* {code}
* .
*/
component extends="commandbox.system.BaseCommand" aliases="mcss" excludeFromHelp=false {


/**
* @path A file globbing pattern of the css files to minify
* @combine Combine all files into one output file (true, default) or minify every file into its own output file (false)
*/
function run( required Globber path, boolean combine=true )  {
    var cssCompressor		 = getInstance( "cssCompressor@commandbox-minify" );
    var currentDirectory 	= shell.pwd();
    var cnt = 0;
    var fileArray = [];
    path.apply( function( thisPath ){
      if (right(thisPath,3) == 'css'){
        fileArray.append(thisPath);
        print.line( 'Adding file ' & thisPath ).toConsole();
        cnt++;
      }
    } );

    if (cnt){
      if (combine){
        cssCompressor.add( fileArray );
        var fileNameOfCompressed	= csscompressor.compress( 'cssall', currentDirectory );
        print.line( 'Merged and compressed into file ' & fileNameOfCompressed ).toConsole();
      } else {
        for (var aFile in fileArray){
          cssCompressor.add( aFile );
          var fileNameOfCompressed	= csscompressor.compress( reReplace( getFileFromPath( aFile ), '\.[^.]*$', '' ), currentDirectory );
          print.line( 'Compressed into file ' & fileNameOfCompressed ).toConsole();
        }
      }
    } else {
      error( 'No Css file found ' );
    }


}
}