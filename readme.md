# A Commandbox module combines and minifies JavaScript files

Please note: This project is at a very early stage. It uses Google Closure Compiler for compression and minification

## Installation

Install the module using Commandbox:
```bash
install commandbox-minify
```

## Configuration

put this setting in your `Theme.cfc` or `ModuleConfig.cfc`

make sure that the syntax is valid Json

```js
this.minifyjs =
		 {"jsfiles" : ['jquery-1.12.4.js'
			,'bootstrap.js'
			,'jquery.validate.js'
			,'slick.js'
		    ,'plugins.js'
		    ,'main.js'
		],
		     "name": "jsall"
         	,"sourceDirectory": "modules/contentbox/themes/XXX/includes/js/source"
         	,"destinationDirectory": "modules/contentbox/themes/XXX/includes/js/destination"
         	,"Optimization": "none" // possible options: none, WHITESPACE_ONLY, SIMPLE_OPTIMIZATIONS, ADVANCED_OPTIMIZATIONS
};
```

## Usage
Call this
```bash
box minify
```
from you project root directory. It will scan for all `Theme.cfc` and `ModuleConfig.cfc` files and see if they contain `this.minifyjs = {"jsfiles" : []}`


ADVANCED_OPTIMIZATIONS options - be carefull with this, better don't choose it

## Versions

0.2
* updated Closure Compliler to latest jar
* added progress bar
* suppress warnings
* fixes

0.1 initial

