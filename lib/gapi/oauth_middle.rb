module Gapi
  
  class OauthMiddle
    
    # the ruby-oauth gem access_token
    def initialize( access_token )
      @access_token = access_token
    end

    def get( domain, path, opts )
      data = opts.collect {|kv| kv.join('=') }.join('&')
      path = "#{path}?#{data}" if data && data.length > 0
      resp, data = @access_token.get( path, {} )
      code = resp.code.to_i
      body = resp.body
      return code, body
    end

  end

end
