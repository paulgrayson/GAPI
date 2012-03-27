require 'test/unit'
require File.join( File.dirname( __FILE__ ), '..', '..', 'gapi.rb' )
require 'date'

class ServiceTest < Test::Unit::TestCase

  def setup
    file = File.join( File.dirname( __FILE__ ), '..', 'data', 'gapi-fixture.xml' )
    middle = Gapi::FixtureMiddle.new( file )
    @service = Gapi::Service.new( middle )
    @service.use_account_with_table_id( 'ga:123' )
    @end = Date.parse( '20120220' )
    @start = @end << 2
  end

  def test_simple_fetch
    dimensions = ['ga:source', 'ga:date']
    metrics = ['ga:visits', 'ga:bounces', 'ga:pageviews', 'ga:goal1Completions','ga:avgTimeOnPage']
    code, data_points = @service.fetch( @start, @end, dimensions, metrics )
    assert_equal 200, code
    assert_equal 288, data_points.length
    assert_equal OpenStruct.new({
      'visits' => '38',
      'date' => '20111220',
      'pageviews' => '53',
      'source' => '(direct)',
      'avg_time_on_page' => '48.666666666666664',
      'goal1completions' => '0',
      'bounces' => '34'
    }), data_points[0]
    assert_equal OpenStruct.new({
      'visits' => '2',
      'date' => '20120220',
      'pageviews' => '2',
      'source' => 'yahoo',
      'avg_time_on_page' => '0.0',
      'goal1completions' => '0',
      'bounces' => '2'
    }), data_points[-1]

  end
end


