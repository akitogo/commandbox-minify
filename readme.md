This module combines and minify JavaScript files

## Installation

Install the module like so:

install commandbox-combine-and-minify-js

# Configuration

put this setting in your Theme.cfc

this.minifyjs =
		 {"jsfiles" = ['jquery-1.12.4.js'
		      			,'bootstrap.js'
		      			,'jquery.validate.js'
		      			,'slick.js'
		      			,'plugins.js'
		      			,'main.js']
		    			,"name": "jsall"
         				,"outputDirectory": "modules/contentbox/themes/XXX/includes/js/src"
         				,"entryDirectory": "modules/contentbox/themes/XXX/includes/js/src"
         				,"Optimisation": "none"}; // possible options: none, WHITESPACE_ONLY, SIMPLE_OPTIMIZATIONS, ADVANCED_OPTIMIZATIONS

## Usage

box minify

ADVANCED_OPTIMIZATIONS options - be carefull with this, better don't choose it



