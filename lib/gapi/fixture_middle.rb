module Gapi

  class FixtureMiddle

    def initialize( filename )
      File.open( filename, 'rb' ) do |f|
        @data = f.read
      end
    end

    def get( domain, path, opts )
      return 200, @data 
    end

  end

end

