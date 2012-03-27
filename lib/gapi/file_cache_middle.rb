require 'pathname'

module Gapi

  # wraps another middle, caches using MD5 hexdigest of path as key
  class FileCacheMiddle

    def initialize( actual_middle, cache_dir, uid )
      @actual_middle = actual_middle
      @cache_dir = Pathname.new( cache_dir )
      @uid = uid
    end

    def get( domain, path, opts )
      data = opts.collect {|kv| kv.join('=') }.join('&')
      uri = path
      uri = "#{path}?#{data}" if data && data.length > 0
      cache_fname = cache_filename_for_uri( uri )
      code = 500
      body = ""
      if File.exists?( cache_fname )
        File.open( cache_fname, 'rb' ) do |f|
          body = f.read
          code = 200
        end
      else
        code, body = @actual_middle.get( domain, path, opts )
        if 200 == code
          File.open( cache_fname, 'wb' ) do |f|
            f.write( body )
          end
        end
      end
      return code, body
    end

  private

    # TODO consider how we'll clear down cache? Could perhaps just
    # delete files created before today
    def cache_filename_for_uri( path )
      uid = Digest::MD5.hexdigest( "#{@uid}:#{path}" )
      # NOTE: this path needs to exist with r/w permissions for webserver
      @cache_dir.join( uid )
    end
  
  end

end

