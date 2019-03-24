/**
 * This is based on a blog post from Ben Nadel
 * https://www.bennadel.com/blog/3065-generating-crc-32-and-adler-32-checksums-in-coldfusion.htm
 * 
 */
    
component  {

    function init() {
        return this;
    }

    /**
    * I compute the Adler-32 checksum for the given string. (From the Java docs) An
    * Adler-32 checksum is almost as reliable as a CRC-32 but can be computed much
    * faster.
    *
    * @input I am the input being checked.
    * @output false
    */
    public numeric function adler32( required string input ) {
        var checksum = createObject( "java", "java.util.zip.Adler32" ).init();
        checksum.update( charsetDecode( input, "utf-8" ) );
        return( checksum.getValue() );
    }
}