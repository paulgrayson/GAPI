# Uses simple_oauth gem and em to make requests
# requires ruby 1.9 as it uses a Fiber to achieve async behaviour without a callback

module Gapi
  
  class EmOauthMiddle

    # connection timeout in seconds
    CONNECT_TIMEOUT_S = 10

    # inactivity timeout in seconds
    INACTIVITY_TIMEOUT_S = 0

    # these are all strings not the access token object from ruby-oauth
    def initialize( consumer_key, consumer_secret, access_token, access_secret )
      @oauth_opts = {
        :consumer_key => consumer_key,
        :consumer_secret => consumer_secret,
        :access_token => access_token,
        :access_token_secret => access_secret
      }
    end

    def get( domain, path, opts )
      data = opts.collect {|kv| kv.join('=') }.join('&')
      path = "#{path}?#{data}" if data && data.length > 0
      http = http_get( "https://#{domain}#{path}" )
      return http.response_header.status, http.response
    end
  
  private

    def http_get( url )
      f = Fiber.current
      f.nil? and raise "http_get called with no current fiber"
      conn = EM::HttpRequest.new( url, :connect_timeout => CONNECT_TIMEOUT_S, :inactivity_timeout => INACTIVITY_TIMEOUT_S )
      conn.use( EventMachine::Middleware::OAuth, @oauth_opts )
      http = conn.get
      http.callback { f.resume( http ) }
      http.errback {|r| f.resume( http ) }
      return Fiber.yield
    end

  end

end

