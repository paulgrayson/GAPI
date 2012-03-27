
Gem::Specification.new do |s|
  s.name        = 'gapi'
  s.version     = '0.0.1'
  s.date        = '2012-03-27'
  s.summary     = "GAPI"
  s.description = "Google Analytics Data Export API wrapper which supports rack style middleware for e.g. testing, caching, oauth requests, event-machine based http etc"
  s.authors     = ["Paul Grayson"]
  s.email       = 'paul.grayson@gmail.com'
  s.files       = Dir[ File.join( File.dirname( __FILE__ ), 'lib', '**', '*.rb' ) ].entries
  s.homepage    = 'http://github.com/paulgrayson/GAPI'
end

