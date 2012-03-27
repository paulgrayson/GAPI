# GAPI gem

GAPI is a simple Google Analytics Data Export API wrapper for ruby
which supports rack style middleware.

GAPI provides middleware for accessing the GA API using different methods of authentication, either:

* email and password - **LoginMiddle**
* or oauth - **OauthMiddle**

There is also middleware for:

* simple file based caching - **FileCacheMiddle**
* making requests using event machine + oauth + Ruby 1.9 fibers (async without callbacks) - **EmOauthMiddle**
* testing using fixture files - **FixtureMiddle**

## Example: fetch some data using email and password auth

<pre>
<code>
  # setup gapi to use simple login with email and password
  middle = Gapi::LoginMiddle.new( 'email-with-access-to-google-analytics@email.com',
                                  'password' )
  service = Gapi::Service.new( middle )

  # fetch the users Google Analytics Account Profiles
  accounts = service.accounts
  accounts.each do |account|
    puts "#{account.table_id}\t#{account.title}"
  end

  # use the first profile
  service.use_account_with_table_id( accounts[0].table_id )

  # fetch some data
  end_date = Date.today() -1
  start_date = end_date &lt;&lt; 1
  code, data_points = service.fetch( start_date,
                                     end_date,
                                     ['ga:date'],
                                     ['ga:visits', 'ga:bounces'],
                                     nil,
                                     nil,
                                     '-ga:date' )
  if code == 200
    data_points.map {|dp|
      "#{dp.date}:\tvisits: #{dp.visits}\tbounces: #{dp.bounces}"
    }.join( "\n" )
  else
    puts "Error: #{code} http status returned"
  end
</code>
</pre>


## Example: fetch some data using file caching and oauth

<pre>
<code>
  # setup gapi to use oauth access token (from ruby-oauth gem)
  oauth_middle = Gapi::OauthMiddle.new( access_token )

  cache_dir = "/path/to/cache/dir"
  # a unique user id for cache, create a new Gapi::Service instance per user
  uid = "user123"  
  # create a FileCacheMiddle that wraps the OauthMiddle
  cache_middle = Gapi::FileCacheMiddle.new( oauth_middle, cache_dir, uid )

  service = Gapi::Service.new( cache_middle )

  # fetch the users Google Analytics Account Profiles
  accounts = service.accounts
  accounts.each do |account|
    puts "#{account.table_id}\t#{account.title}"
  end

  # use the first profile
  service.use_account_with_table_id( accounts[0].table_id )

  # fetch some data
  end_date = Date.today() -1
  start_date = end_date &lt;&lt; 1
  code, data_points = service.fetch( start_date,
                                     end_date,
                                     ['ga:date'],
                                     ['ga:visits', 'ga:bounces'],
                                     nil,
                                     nil,
                                     '-ga:date' )
  if code == 200
    data_points.map {|dp|
      "#{dp.date}:\tvisits: #{dp.visits}\tbounces: #{dp.bounces}"
    }.join( "\n" )
  else
    puts "Error: #{code} http status returned"
  end
</code>
</pre>

## Example - testing using fixture files

You can plug in an instance of FixtureMiddle with a fixture file of data to test against.
You could capture this data earlier from a real request using FileCacheMiddle.
Copy and rename the cached file as your new test fixture.

See test/unit/file_cache_middle_test.rb for a full example.

<pre>
<code>
  # create a FixtureMiddle with path to xml file containing a response from Google Analytics
  fixture_middle = Gapi::FixtureMiddle.new( 'file-with-xml-response-from-ga.xml' )
  service = Gapi::Service.new( fixture_middle )
</code>
</pre>


