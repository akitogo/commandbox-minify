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
this.minifyjs =
		 {"jsfiles" : ["jquery-1.12.4.js"
			,"bootstrap.js"
			,"jquery.validate.js"
			,"slick.js"
		    ,"plugins.js"
		    ,"main.js"
		],
			 "name": "jsall"
			,"minified:""
         	,"sourceDirectory": "modules/contentbox/themes/XXX/includes/js/source"
         	,"destinationDirectory": "modules/contentbox/themes/XXX/includes/js/destination"
         	,"optimization": "none"
};
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

