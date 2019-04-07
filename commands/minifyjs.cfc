/**
* Compressing and merging files from a location use
* .
* {code:bash}
* minifyjs "/path/to/js/files/*"
* mjs "/path/to/js/files/*"
* {code}
* . 
*/
component extends="commandbox.system.BaseCommand" aliases="mjs" excludeFromHelp=false {


/**
*
*/
function run( required Globber path  )  {
  var jscomplier			  = getInstance( "js@commandbox-minify" );
  var currentDirectory 	= shell.pwd();
  var cnt               = 0;
  var myArr             = path.asArray().matches();
  var fileArray         = [];
  path.apply( function( thisPath ){
    if (right(thisPath,2) == 'js'){
      fileArray.append(thisPath);
      print.line( 'Adding file ' & thisPath ).toConsole();
      cnt++;
    }
  } );

  if (cnt){
    var fileNameOfCompressed	= jscomplier.compile(fileArray,currentDirectory,'jsall');
    print.greenline( 'Merged and compressed into file ' & fileNameOfCompressed ).toConsole();
  } else {
    error( 'No JS file found ' );
  }


}
}