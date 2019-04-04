# A Commandbox module combines and minifies JavaScript and CSS files

Please note: This project is at a early stage. 
It uses Google Closure Compiler for compression and minification of JS files.
For CSS a CFML port of YUI compressor is used.

## Installation

Install the module using Commandbox:
```bash
box install commandbox-minify
```

## Usage
Call this (if you want to use it with Coldbox)
```bash
box minify
```
from you project root directory. It will scan for all `Theme.cfc` and `ModuleConfig.cfc` files and see if they contain `this.minifyjs = {"jsfiles" : []}`


ADVANCED_OPTIMIZATIONS options - be carefull with this, better don"t choose it
possible options are: none, WHITESPACE_ONLY, SIMPLE_OPTIMIZATIONS, ADVANCED_OPTIMIZATIONS

## Configuration if used with Coldbox

put this setting in your `Theme.cfc` or `ModuleConfig.cfc`

make sure that the syntax is valid Json

```js
	this.minify =
	[
	 { "jshead" : [
		"theme/includes/justified/jquery.justifiedGallery.min.js"
	   ,"theme/includes/kendoui.for.jquery.2018.1.221.commercial/js/kendo.all.min.js"
	   ,"theme/includes/js/jquery.functions.js"
	   ,"akibase-core/includes/jquery.cookie.js"
	   ,"akibase-core/includes/jquery.akibase.js"
	   ,"theme/includes/startpage/animationhandler.js"
	   ,"theme/includes/js/jquery.fileupload.js"
	   ,"theme/includes/js/jquery.scripts.js"
   ],
   		 "type": "js"
  		,"name": "jsall"
		,"minified":"cssall-756566207.css"
		,"sourceDirectory": "modules"
		,"destinationDirectory": "modules/theme/includes/js"
		,"optimization": "none" 
   }
   ,
   { "cssHead" : [
		 "theme/includes/bootstrap41/css/bootstrap.min.css"
		,"theme/includes/justified/justifiedGallery.min.css"
		,"theme/includes/css/custom.css"
		,"theme/includes/akiicons/css/akiicons.css"
		,"theme/includes/css/bootstrap-datepicker.css"
		,"theme/includes/kendoui.for.jquery.2018.1.221.commercial/styles/kendo.bootstrap-v4.min.css"
	],
		"type": "css"
	 	,"name": "cssall"
		,"minified":""
		,"sourceDirectory": "modules"
		,"destinationDirectory": "modules/theme/includes/css"
	} 
	];
```

## Versions
0.3
* ported yui compressor to cfml
* added css compression

0.2
* updated Closure Compiler to latest jar
* added progress bar
* suppress warnings
* fixes

0.1 initial

