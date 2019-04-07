/**
* Compressing and merging files from a location use
* .
* {code:bash}
* minifycss "/path/to/css/files/*"
* mcss "/path/to/css/files/*"
* {code}
* . 
*/
component extends="commandbox.system.BaseCommand" aliases="mcss" excludeFromHelp=false {


/**
 *
 */
function run( required Globber path  )  {
    var cssCompressor		 = getInstance( "cssCompressor@commandbox-minify" );
    var currentDirectory 	= shell.pwd();
    var cnt = 0;
    var myArr = path.asArray().matches();
    path.apply( function( thisPath ){
      if (right(thisPath,3) == 'css'){
        cssCompressor.add(thisPath);
        print.line( 'Adding file ' & thisPath ).toConsole();
        cnt++;
      }
    } );

    if (cnt){
      var fileNameOfCompressed	= csscompressor.compress( 'cssall', currentDirectory );
      print.line( 'Merged and compressed into file ' & fileNameOfCompressed ).toConsole();
    } else {
      error( 'No Css file found ' );
    }


}
}