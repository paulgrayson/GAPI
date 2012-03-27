# GAPI gem

GAPI is a simple Google Analytics Data Export API wrapper for ruby
which supports rack style middleware

## Example: fetch some data using email and password auth

<pre>
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
  start_date = end_date << 1
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
</pre>

