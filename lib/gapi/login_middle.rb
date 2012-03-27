module Gapi
  
  class LoginMiddle

    def initialize( email, password, source="gapi-v1" )
      @auth_token = login( email, password, "source=#{source}" )
    end

   def get( domain, path, opts )
      http = Net::HTTP.new( domain, 443 )
      http.use_ssl = true
      data = opts.collect {|kv| kv.join('=') }.join('&')
      path = "#{path}?#{data}" if data && data.length > 0
      resp, data = http.get( path, auth_headers )
      code = resp.code.to_i
      body = resp.body
      return code, body
    end

  private
    
    def login( email, password, source )
      params = {"Email" => email, "Passwd" => password, "accountType" => "GOOGLE", "source" => source, "service" => "analytics"}
      code, body = post( "www.google.com", "/accounts/ClientLogin", params );
      if code == 200
        body.split( "\n" ).each do |line|
          if line.match( /^Auth/ )
            return line
          end
        end
      else
        nil
      end
    end

    def auth_header
      {"Authorization" => "AuthSub token=#{@auth_token}"}
    end

    def post( domain, path, opts )
      http = Net::HTTP.new( domain, 443 )
      http.use_ssl = true
      data = opts.collect {|kv| kv.join('=') }.join('&')
      headers = {'Content-Type' => 'application/x-www-form-urlencoded'}.merge( auth_headers )
      resp, data = http.post( path, data, headers )
      code = resp.code.to_i
      return code, resp.body
    end
 
  end

end
