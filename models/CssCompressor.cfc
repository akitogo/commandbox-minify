component {

	property name = "srcsb";
	property name = "files";

	private function newStringBuffer() {
		return createObject( "java", "java.lang.StringBuffer" );
	}

	private function newPattern( required String tocompile ) {
		return createObject( "java", "java.util.regex.Pattern" ).compile( arguments.tocompile );
	}

	private function getMainStringBuffer() {
		return variables.srcsb;
	}

	public CssCompressor function init() {
		variables.srcsb	= this.newStringBuffer();
		variables.files	= [];
		return this;
	}

	public CssCompressor function add( required  Any addfiles ) {
		if( not isArray( arguments.addfiles ) ) {
			arguments.addfiles	= [ arguments.addfiles ];
		}
		for( var a in arguments.addfiles ) {
			arrayAppend( variables.files, a );
		}
		return this;
	}

	public String function compress( required String cssdir ) {
		this.prepareStringBuffer();

		var css				= this.getMainStringBuffer().toString();
		var sb				= this.newStringBuffer().append( css );
		var startIndex		= 0;
		var endIndex		= 0;
		var totallen		= css.length();
		var token			= '';
		var placeholder		= '';
		var comments		= [];
		var preservedTokens	= [];
		var commentbegin	= "/*"; /* */

		startIndex	= sb.indexOf( commentbegin, startIndex );

		while( startIndex gte 0 ) {
            endIndex = sb.indexOf( "*/", startIndex + 2 );
            if (endIndex < 0 ) {
                endIndex = totallen;
            }

            token = sb.substring( startIndex + 2, endIndex );
            arrayAppend( comments, token );
            sb.replace( startIndex + 2, endIndex, "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" & ( arrayLen( comments ) ) & "___" );
            startIndex += 2;
            startIndex	= sb.indexOf( commentbegin, startIndex );
        }
        css = sb.toString();
		css = this.preserveToken( css, "url", "(?i)url\(\s*([\""']?)data\:", true, preservedTokens );
        css = this.preserveToken( css, "calc",  "(?i)calc\(\s*([\""']?)", false, preservedTokens );
		css = this.preserveToken( css, "progid:DXImageTransform.Microsoft.Matrix", "(?i)progid:DXImageTransform.Microsoft.Matrix\s*([\""']?)", false, preservedTokens );

		// preserve strings so their content doesn't get accidentally minified
        sb 			= this.newStringBuffer();
        var p 		= this.newPattern( "(""([^\\""]|\\.|\\)*"")|('([^\\']|\\.|\\)*')" );
        var m 		= p.matcher(css);

        while ( m.find() ) {
            token 		= m.group();
            var quote 	= token.charAt( 0 );
            token 		= token.substring( 1, token.length() - 1 );

            // maybe the string contains a comment-like substring?
            // one, maybe more? put'em back then
            if ( token.indexOf("___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_") gte 0 )  {
                for ( var i = 1; i lte arrayLen( comments ); i++ ) {
                    token = token.replace( "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" & i & "___", comments[ i ] );
                }
            }

            // minify alpha opacity in filter strings
            token = token.replaceAll( "(?i)progid:DXImageTransform.Microsoft.Alpha\(Opacity=", "alpha(opacity=" );

			arrayAppend( preservedTokens, token );
            var preserver 	= quote & "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___" & quote;
            m.appendReplacement( sb, preserver );
        }
        m.appendTail( sb );
		css = sb.toString();

		// strings are safe, now wrestle the comments
        for ( var i = 1; i lte arrayLen( comments ); i++ ) {

            token 		= comments[ i ];
            placeholder = "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" & i & "___";

            // ! in the first position of the comment means preserve
            // so push to the preserved tokens while stripping the !
            if ( token.startsWith( "!" ) ) {
            	arrayAppend( preservedTokens, token );
                css = css.replace( placeholder,  "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___" );
                continue;
            }

            // \ in the last position looks like hack for Mac/IE5
            // shorten that to /*\*/ and the next one to /**/
            if ( token.endsWith( "\" ) ) {
            	arrayAppend( preservedTokens, "\" );
                css 		= css.replace( placeholder,  "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___" );
                i = i + 1; // attn: advancing the loop
                arrayAppend( preservedTokens, "" );
                css = css.replace( "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" & i & "___",  "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___" );
                continue;
            }

            // keep empty comments after child selectors (IE7 hack)
            // e.g. html >/**/ body
            if ( token.length() eq 0 ) {
                startIndex = css.indexOf( placeholder );
                if ( startIndex gt 2 ) {
                    if( css.charAt( startIndex - 3 ) eq '>' ) {
                    	arrayAppend( preservedTokens, "" );
                        css = css.replace( placeholder,  "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___" );
                    }
                }
            }

            // in all other cases kill the comment
            css = css.replace( commentbegin & placeholder & "*/", "" );
		}

		// preserve \9 IE hack
        var backslash9 = "\9";
        while ( css.indexOf(backslash9) gte 0 ) {
        	arrayAppend( preservedTokens, backslash9 );
            css = css.replace( backslash9,  "___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( preservedTokens ) ) & "___");
     	}

        // Normalize all whitespace strings to single spaces. Easier to work with that way.
        css = css.replaceAll( "\s+", " " );

        // Remove the spaces before the things that should not have spaces before them.
        // But, be careful not to turn "p :link {...}" into "p:link{...}"
        // Swap out any pseudo-class colons with the token, and then swap back.
        sb 		= this.newStringBuffer();
        p 		= this.newPattern( "(^|\})((^|([^\{:])+):)+([^\{]*\{)" );
        m 		= p.matcher(css);

        while (m.find()) {
            var s 	= m.group();
            s 		= s.replaceAll( ":", "___YUICSSMIN_PSEUDOCLASSCOLON___" );
            s 		= s.replaceAll( "\\", "\\\\" ).replaceAll( "\$", "\\\$" );
            m.appendReplacement( sb, s );
        }
        m.appendTail( sb );
		css = sb.toString();

		// Remove spaces before the things that should not have spaces before them.
        css 		= css.replaceAll( "\s+([!{};:>+\(\)\],])", "$1" );
        // Restore spaces for !important
        css 		= css.replaceAll( "!important", " !important" );
        // bring back the colon
        css 		= css.replaceAll( "___YUICSSMIN_PSEUDOCLASSCOLON___", ":" );

        // retain space for special IE6 cases
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i):first\-(line|letter)(\{|,)" );
        m 			= p.matcher( css );
        while ( m.find() ) {
            m.appendReplacement( sb, ":first-" & m.group( 1 ).toLowerCase() & " " & m.group( 2 ) );
        }
        m.appendTail( sb );
		css 		= sb.toString();

		// no space after the end of a preserved comment
        css 		= css.replaceAll( "\*/ ", "*/" );

        // If there are multiple @charset directives, push them to the top of the file.
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)^(.*)(@charset)( ""[^""]*"";)" );
        m 			= p.matcher( css );
        while( m.find() ) {
            var s = m.group( 1 ).replaceAll( "\\", "\\\\" ).replaceAll( "\$", "\\\$" );
            m.appendReplacement( sb, m.group( 2 ).toLowerCase() & m.group( 3 ) & s );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // When all @charset are at the top, remove the second and after (as they are completely ignored).
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)^((\s*)(@charset)( [^;]+;\s*))+" );
        m 			= p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, m.group( 2 ) & m.group( 3 ).toLowerCase() & m.group( 4 ) );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // lowercase some popular @directives (@charset is done right above)
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)@(font-face|import|(?:-(?:atsc|khtml|moz|ms|o|wap|webkit)-)?keyframe|media|page|namespace)" );
        m 			= p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, '@' & m.group( 1 ).toLowerCase() );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // lowercase some more common pseudo-elements
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i):(active|after|before|checked|disabled|empty|enabled|first-(?:child|of-type)|focus|hover|last-(?:child|of-type)|link|only-(?:child|of-type)|root|:selection|target|visited)" );
        m 			= p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, ':' & m.group( 1 ).toLowerCase() );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // lowercase some more common functions
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i):(lang|not|nth-child|nth-last-child|nth-last-of-type|nth-of-type|(?:-(?:moz|webkit)-)?any)\(" );
        m 			= p.matcher( css );
        while ( m.find() ) {
            m.appendReplacement( sb, ':' & m.group( 1 ).toLowerCase() & '(' );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // lower case some common function that can be values
        // NOTE: rgb() isn't useful as we replace with #hex later, as well as and() is already done for us right after this
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)([:,\( ]\s*)(attr|color-stop|from|rgba|to|url|(?:-(?:atsc|khtml|moz|ms|o|wap|webkit)-)?(?:calc|max|min|(?:repeating-)?(?:linear|radial)-gradient)|-webkit-gradient)" );
        m = p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, m.group( 1 ) & m.group( 2 ).toLowerCase() );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // Put the space back in some cases, to support stuff like
        // @media screen and (-webkit-min-device-pixel-ratio:0){
        css 		= css.replaceAll( "(?i)\band\(", "and (" );

        // Remove the spaces after the things that should not have spaces after them.
        css 		= css.replaceAll( "([!{}:;>+\(\[,])\s+", "$1" );

        // remove unnecessary semicolons
        css 		= css.replaceAll( ";+}", "}" );

		// Replace 0(px,em,%) with 0.
        var oldCss	= '';
        p 			= this.newPattern( "(?i)(^|: ?)((?:[0-9a-z-.]+ )*?)?(?:0?\.)?0(?:px|em|%|in|cm|mm|pc|pt|ex|deg|g?rad|m?s|k?hz)" );
        do {
        	oldCss 	= css;
        	m = p.matcher( css );
        	css = m.replaceAll( "$1$20" );
        } while ( css neq oldCss );

        // Replace 0(px,em,%) with 0 inside groups (e.g. -MOZ-RADIAL-GRADIENT(CENTER 45DEG, CIRCLE CLOSEST-SIDE, ORANGE 0%, RED 100%))
        p 			= this.newPattern( "(?i)\( ?((?:[0-9a-z-.]+[ ,])*)?(?:0?\.)?0(?:px|em|%|in|cm|mm|pc|pt|ex|deg|g?rad|m?s|k?hz)" );
        do {
        	oldCss = css;
        	m = p.matcher( css );
        	css = m.replaceAll( "($10" );
        } while ( css neq oldCss );

        // Replace x.0(px,em,%) with x(px,em,%).
        css 		= css.replaceAll( "([0-9])\.0(px|em|%|in|cm|mm|pc|pt|ex|deg|g?rad|m?s|k?hz| |;)", "$1$2" );

        // Replace 0 0 0 0; with 0.
        css 		= css.replaceAll( ":0 0 0 0(;|})", ":0$1" );
        css 		= css.replaceAll( ":0 0 0(;|})", ":0$1" );
        css 		= css.replaceAll( "(?<!flex):0 0(;|})", ":0$1" );


        // Replace background-position:0; with background-position:0 0;
        // same for transform-origin
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)(background-position|webkit-mask-position|transform-origin|webkit-transform-origin|moz-transform-origin|o-transform-origin|ms-transform-origin):0(;|})" );
        m 			= p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, m.group( 1 ).toLowerCase() & ":0 0" & m.group( 2 ) );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // Replace 0.6 to .6, but only when preceded by : or a white-space
		css 		= css.replaceAll( "(:|\s)0+\.(\d+)", "$1.$2" );

		// Shorten colors from rgb(51,102,153) to #336699
        // This makes it more likely that it'll get further compressed in the next step.
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "rgb\s*\(\s*([0-9,\s]+)\s*\)" );
        m 			= p.matcher( css );

        while( m.find() ) {
            var rgbcolors 	= listToArray( m.group( 1 ) );
            var hexcolor 	= this.newStringBuffer().append( "##" );
            for( var i = 1; i lte rgbcolors.length; i++ ) {
                var value 	= rgbcolors[ i ];
                if ( value lt 16 ) {
                    hexcolor.append( "0" );
                }

                // If someone passes an RGB value that's too big to express in two characters, round down.
                // Probably should throw out a warning here, but generating valid CSS is a bigger concern.
                if ( value > 255 ) {
                    value = 255;
                }
                hexcolor.append( this.stringToHex( value ) );
            }
            m.appendReplacement( sb, hexcolor.toString() );
        }
        m.appendTail( sb );
		css 		= sb.toString();

		// Shorten colors from #AABBCC to #ABC. Note that we want to make sure
        // the color is not preceded by either ", " or =. Indeed, the property
        //     filter: chroma(color="#FFFFFF");
        // would become
        //     filter: chroma(color="#FFF");
        // which makes the filter break in IE.
        // We also want to make sure we're only compressing #AABBCC patterns inside { }, not id selectors ( #FAABAC {} )
        // We also want to avoid compressing invalid values (e.g. #AABBCCD to #ABCD)

        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(\=\s*?[""']?)?" & "##([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])" & "(:?\}|[^0-9a-fA-F{][^{]*?\})" );
	    m 			= p.matcher( css );

        var index 	= 0;

        while( m.find( index ) ) {
            sb.append( css.substring( index, m.start() ) );
            var isFilter = ( not isNull( m.group( 1 ) ) and m.group( 1 ) neq "" );

            if( isFilter ) {
                // Restore, as is. Compression will break filters
                sb.append( m.group(1) & "##" & m.group( 2 ) & m.group( 3 ) & m.group( 4 ) & m.group( 5 ) & m.group(6) & m.group( 7 ) );
            } else {
                if( m.group( 2 ).equalsIgnoreCase( m.group( 3 ) ) and
                    m.group( 4 ).equalsIgnoreCase(m.group( 5 ) ) and
                    m.group( 6 ).equalsIgnoreCase( m.group( 7 ) ) ) {

                    // #AABBCC pattern
                    sb.append( "##" & ( m.group( 3 ) & m.group( 5 ) & m.group( 7 ) ).toLowerCase() );

                } else {

                    // Non-compressible color, restore, but lower case.
                    sb.append( "##" & ( m.group( 2 ) & m.group( 3 ) & m.group( 4 ) & m.group( 5 ) & m.group( 6 ) & m.group( 7 ) ).toLowerCase() );
                }
            }

            index = m.end( 7 );
        }

        sb.append( css.substring( index ) );
		css 		= sb.toString();

		// Replace #f00 -> red
        css 		= css.replaceAll( "(:|\s)(##f00)(;|})", "$1red$3" );
        css 		= css.replaceAll( "(:|\\s)(##000080)(;|})", "$1navy$3" );
        css 		= css.replaceAll( "(:|\\s)(##808080)(;|})", "$1gray$3" );
        css 		= css.replaceAll( "(:|\\s)(##808000)(;|})", "$1olive$3" );
        css 		= css.replaceAll( "(:|\\s)(##800080)(;|})", "$1purple$3" );
        css 		= css.replaceAll( "(:|\\s)(##c0c0c0)(;|})", "$1silver$3" );
        css 		= css.replaceAll( "(:|\\s)(##008080)(;|})", "$1teal$3" );
        css 		= css.replaceAll( "(:|\\s)(##ffa500)(;|})", "$1orange$3" );
        css 		= css.replaceAll( "(:|\\s)(##800000)(;|})", "$1maroon$3" );

        // border: none -> border:0
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "(?i)(border|border-top|border-right|border-bottom|border-left|outline|background):none(;|})" );
        m 			= p.matcher( css );
        while( m.find() ) {
            m.appendReplacement( sb, m.group( 1 ).toLowerCase() & ":0" & m.group( 2 ) );
        }
        m.appendTail( sb );
        css 		= sb.toString();

        // shorter opacity IE filter
        css 		= css.replaceAll( "(?i)progid:DXImageTransform.Microsoft.Alpha\(Opacity=", "alpha(opacity=" );

        // Find a fraction that is used for Opera's -o-device-pixel-ratio query
        // Add token to add the "\" back in later
        css 		= css.replaceAll( "\(([\-A-Za-z]+):([0-9]+)\/([0-9]+)\)", "($1:$2___YUI_QUERY_FRACTION___$3)" );

        // Remove empty rules.
        css 		= css.replaceAll( "[^\}\{/;]+\{\}", "" );

        // Add "\" back to fix Opera -o-device-pixel-ratio query
        css 		= css.replaceAll( "___YUI_QUERY_FRACTION___", "/" );

        // TODO: Should this be after we re-insert tokens. These could alter the break points. However then
        // we'd need to make sure we don't break in the middle of a string etc.
        var linebreakpos	= 8000;
        if( linebreakpos lte 0 ) {
            // Some source control tools don't like it when files containing lines longer
            // than, say 8000 characters, are checked in. The linebreak option is used in
            // that case to split long lines after a specific column.
            var i 				= 0;
            var linestartpos 	= 0;
            sb 					= this.StringBuffer().append( css );

            while ( i lt sb.length() ) {
                var c = sb.charAt( i++ );
                if( c eq '}' and i - linestartpos gt linebreakpos ) {
                    sb.insert( i, "\n" );
                    linestartpos = i;
                }
            }

            css 	= sb.toString();
		}

		// Replace multiple semi-colons in a row by a single one
        // See SF bug #1980989
        css 		= css.replaceAll( ";;+", ";" );

        // restore preserved comments and strings
        for( var i = 1; i lte arrayLen( preservedTokens ); i++ ) {
            css 	= css.replace( "___YUICSSMIN_PRESERVED_TOKEN_" & i & "___", preservedTokens[ i ] );
        }

        // Add spaces back in between operators for css calc function
        // https://developer.mozilla.org/en-US/docs/Web/CSS/calc
        // Added by Eric Arnol-Martin (earnolmartin@gmail.com)
        sb 			= this.newStringBuffer();
        p 			= this.newPattern( "calc\([^\)]*\)" );
        m 			= p.matcher( css );
        while( m.find() ) {
            var s 	= m.group();

            s 		= s.replaceAll( "(?<=[-|%|px|em|rem|vw|\d]+)\+", " + " );
            s 		= s.replaceAll( "(?<=[-|%|px|em|rem|vw|\d]+)\-", " - " );
            s 		= s.replaceAll( "(?<=[-|%|px|em|rem|vw|\d]+)\*", " * " );
            s 		= s.replaceAll( "(?<=[-|%|px|em|rem|vw|\d]+)\/", " / " );

            m.appendReplacement( sb, s );
        }
        m.appendTail( sb );
        css 		= sb.toString();



        // Trim the final string (for any leading or trailing white spaces)
		css 		= css.trim();

		var file	= arguments.cssdir & hash( css ) & ".css";
		if( fileExists( file ) )
			fileDelete( file );
		fileWrite( file, css );


		return file;
	}


	private void function prepareStringBuffer() {
		for( var f in variables.files ) {
			if( fileExists( f ) ) {
				var data	= fileRead( f );
				this.getMainStringBuffer().append( data );
			}
		}
	}

	private String function preserveToken( required String css, required String preservedToken, required String tokenRegex, required boolean removeWhiteSpace, required array preservedTokens ) {

        var maxIndex 		= arguments.css.length() - 1;
        var appendIndex 	= 0;
        var sb 				= this.newStringBuffer();

		var p				= this.newPattern( arguments.tokenRegex );
		var m				= p.matcher( css );

        while ( m.find() ) {

            var startIndex 		= m.start() + ( preservedToken.length() + 1 );
            var terminator 		= m.group( 1 );

            // skip this, if CSS was already copied to "sb" upto this position
            if ( m.start() lt appendIndex ) {
                continue;
            }

            if ( terminator.length() eq 0 ) {
                terminator = ")";
            }

            var foundTerminator = false;

            var endIndex = m.end() - 1;
            while( foundTerminator eq false and endIndex + 1 lte maxIndex ) {
                endIndex = css.indexOf( terminator, endIndex + 1 );

                if ( endIndex lte 0 ) {
                    break;
                } else if ( ( endIndex gt 0) and ( css.charAt( endIndex - 1 ) != '\' ) ) {
                    foundTerminator = true;
                    if ( terminator neq ")" ) {
                        endIndex = css.indexOf( ")", endIndex );
                    }
                }
            }

            // Enough searching, start moving stuff over to the buffer
            sb.append( css.substring( appendIndex, m.start() ) );

            if ( foundTerminator ) {
                var token = css.substring( startIndex, endIndex );
                if( removeWhiteSpace )
                    token = token.replaceAll( "\s+", "" );
                arrayAppend( arguments.preservedTokens, token );

                var preserver = preservedToken & "(___YUICSSMIN_PRESERVED_TOKEN_" & ( arrayLen( arguments.preservedTokens) ) & "___)";
                sb.append( preserver );

                appendIndex = endIndex + 1;
            } else {
                // No end terminator found, re-add the whole match. Should we throw/warn here?
                sb.append( css.substring( m.start(), m.end() ) );
                appendIndex = m.end();
            }
        }
        sb.append( css.substring( appendIndex ) );
        return sb.toString();
	}

	private String function stringToHex( required String stringValue ){
        var binaryValue 	= stringToBinary( stringValue );
        var hexValue 		= binaryEncode( binaryValue, "hex" );
        return( lcase( hexValue ) );
    }


}