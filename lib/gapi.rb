Dir[ File.join( File.dirname( __FILE__ ),'gapi', '*.rb' ) ].each {|f| puts( f); require( f )}

