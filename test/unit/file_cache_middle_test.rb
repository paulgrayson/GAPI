require 'test/unit'
require File.join( File.dirname( __FILE__ ), '..', '..', 'gapi.rb' )
require 'date'
require 'mocha'

class FileCacheMiddleTest < Test::Unit::TestCase

  def setup
    file = File.join( File.dirname( __FILE__ ), '..', 'data', 'gapi-fixture.xml' )
    @fixture_middle = Gapi::FixtureMiddle.new( file )
    @uid = 'user123'
    @cache_dir = File.expand_path( File.join( File.dirname( __FILE__ ), '..', '..', 'tmp', 'cache' ) )
    @cache_glob = "#{@cache_dir}/*"
    if File.exists?( @cache_dir )
      clean_cache_dir
    else
      Dir.mkdir( @cache_dir )
    end
    cache_middle = Gapi::FileCacheMiddle.new( @fixture_middle, @cache_dir, @uid )
    @service = Gapi::Service.new( cache_middle )
    @service.use_account_with_table_id( 'ga:123' )
    @end = Date.parse( '20120220' )
    @start = @end << 2
  end

  def clean_cache_dir
    Dir[ @cache_glob ].each {|f| File.delete( f ) }
  end

  def cache_empty?
    Dir[ @cache_glob ].empty?
  end

  def do_fetch( start_date=@start, end_date=@end )
    dimensions = ['ga:source', 'ga:date']
    metrics = ['ga:visits', 'ga:bounces', 'ga:pageviews', 'ga:goal1Completions','ga:avgTimeOnPage']
    code, data_points = @service.fetch( start_date, end_date, dimensions, metrics )
  end

  def test_cache_written
    assert cache_empty?, "Cache is not empty"
    code, data_points = do_fetch
    assert_equal 200, code
    assert_equal 288, data_points.length
    assert !cache_empty?, "Cache should not be empty after request"
  end

  def test_cache_read
    assert cache_empty?, "Cache is not empty"
    code, data_points = do_fetch
    assert_equal 200, code
    assert_equal 288, data_points.length
    assert !cache_empty?, "Cache should not be empty after request"
    @fixture_middle.stubs(:get).never
    code, data_points = do_fetch
    assert_equal 200, code
    assert_equal 288, data_points.length
  end

  def test_new_dimensions_metrics_misses_cache
    @fixture_middle.stubs(:get).once
    code, data_points = @service.fetch( @start, @end, ['ga:date'], ['ga:visits'] )
  end

  def test_new_dates_misses_cache
    @fixture_middle.stubs(:get).once
    code, data_points = do_fetch( @start +1, @end )
  end
end


