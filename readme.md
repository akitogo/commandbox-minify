# A Commandbox module which combines and minifies JavaScript and CSS files

It uses Google Closure Compiler for compression and minification of JS files.
For CSS a CFML port of YUI compressor is used.

## Installation

Install the module using Commandbox:
```bash
box install commandbox-minify
```

## Usage
`box minifycss "path/to/css/files/*"` or `box mcss "path/to/css/files/*"` for compressing css files from a location

`box minifjs "path/to/js/files/*"` or `box mjs "path/to/js/files/*"` for compressing js files from a location

Call this (if you want to use it with Coldbox)
```bash
box minify
```
from your project root directory. It will scan for all `Theme.cfc` and `ModuleConfig.cfc` files and sees if any contains `this.minify = { "nameItAsYouLike" :  {}, "nameItAsYouLike2" :  {} }`

Make sure that `this.minify` is a valid json. Currently a regex is used to find and parse it.


ADVANCED_OPTIMIZATIONS options - be carefull with this, better don"t choose it
possible options are: none, WHITESPACE_ONLY, SIMPLE_OPTIMIZATIONS, ADVANCED_OPTIMIZATIONS

## Configuration if used with Coldbox

put this setting in your `Theme.cfc` or `ModuleConfig.cfc`. Make sure that the syntax is valid Json.

Here is an example file:
* `nameItAsYouLike` as written, name your block as you like
* `files` array of files to be minified and combined
* `type` can be js or css
* `name` name of the file containing all minified and combined files
* `minified` after executing `minify` the name plus and hash will be written here
* `sourceDirectory` this is your base dir starting from web root. Enter e.g. modules here
* `destinationDirectory` the minfied file will be placed here
* `optimization` will be used for js minification only, see above ADVANCED_OPTIMIZATIONS


```js
	this.minify = {
	"nameItAsYouLike" :  { 'files':  [
		"theme/includes/justified/jquery.justifiedGallery.min.js"
	   ,"theme/includes/kendoui.for.jquery.2018.1.221.commercial/js/kendo.all.min.js"
	   ,"theme/includes/js/jquery.functions.js"
	   ,"theme/includes/js/jquery.fileupload.js"
	   ,"theme/includes/js/jquery.scripts.js"
   ],
   		 "type": "js"
  		,"name": "jsall"
		,"minified":"willBeFilledAutomatically"
		,"sourceDirectory": "this is your base dir starting from web root. Enter e.g. modules here"
		,"destinationDirectory": "modules/theme/includes/js"
		,"optimization": "none"
   }
   ,
   "nameItAsYouLike2" : { 'files': [
		 "bootstrap41/css/bootstrap.min.css"
		,"justified/justifiedGallery.min.css"
		,"css/custom.css"
		,"css/bootstrap-datepicker.css"
	],
		"type": "css"
	 	,"name": "cssall"
		,"minified":"willBeFilledAutomatically"
		,"sourceDirectory": "modules/theme/includes"
		,"destinationDirectory": "modules/theme/includes/css"
	}
   	};
```
## If used without Coldbox

You can place a `Theme.cfc` anywhere in your project. Add at least `this.minify` structure as mentioned above

## Versions
0.4.1
* fixing an error with YuiCompressor and inline images

0.4
* added `box minifycss path/to/css/files/*` or `box mcss path/to/css/files/*` for compressing css files from a location
* added `box minifjs path/to/css/files` or `box js path/to/js/files` for compressing js files from a location

0.3.1
* changed structure of `this.minify`

0.3
* ported yui compressor to cfml
* added css compression

0.2
* updated Closure Compiler to latest jar
* added progress bar
* suppress warnings
* fixes

0.1 
* initial

