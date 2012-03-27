require 'net/http'
require 'net/https'
require 'openssl'
require 'nokogiri'
require 'ostruct'
require 'cgi'

module Gapi

  class Service
    
    # middle is used to fetch using net:http, oauth, em etc
    def initialize( middle )
      @profile_id = nil
      @middle = middle
    end
   
    # dimensions and metrics are arrays e.g. ['ga:date', 'ga:sources'] - see Google Analytics Data Export API
    # filters and sort follow Google Analytics Data Export API documentation e.g. to sort most recent date first: -ga:date
    # Must be called from a fiber if EmOauthMiddle used
    def fetch( start_date, end_date, dimensions, metrics, filters=nil, max_results=nil, sort=nil )
      opts = query_opts( start_date, end_date, dimensions, metrics, filters, max_results, sort )
      code, body = @middle.get( "www.google.com", "/analytics/feeds/data", opts )
      if code == 200
        return code, parse( body )
      else
        return code, nil
      end
    end

    # Must be called from a fiber if EmOauthMiddle used
    def accounts
      code, body = @middle.get( "www.google.com", "/analytics/feeds/accounts/default", {:date => Time.now.strftime("%Y-%m-%d")} )
      if code == 200
        return code, parse_accounts( body )
      else
        return code, nil
      end
    end
    
    def use_account_with_table_id( table_id )
      @profile_id = table_id.split(':').last
    end
    
    def use_account_with_title( title )
      code, accs = accounts
      account = accs.find {|acc| acc.title == title}
      if account
        @profile_id = use_account_with_table_id( account.table_id )
      else
        nil
      end
    end

    def self.to_underlined( str )
      str.gsub( /[a-z]([A-Z])/ ) {|m| m.insert( 1, "_" )}.downcase
    end
    
  private

    def parse( body )
      doc = Nokogiri::XML(body)
      results = (doc/:entry).collect do |entry|
        hash = {}        
        # as (entry/'dxp:metric') with namespace doesn't work, instead iterate over all sub-elements   
        (entry/'*').each do |element|
          if element.name == "dimension" or element.name == "metric"
            name = Gapi::Service.to_underlined( element[:name].sub(/^ga\:/,'') )
            hash[name] = element[:value]
          end
        end
        OpenStruct.new(hash)
      end
      results
    end

    def parse_accounts( body )
      doc = Nokogiri::XML(body)
      results = (doc/:entry).collect do |entry|
        hash = {}        
        # as (entry/'dxp:metric') with namespace doesn't work, instead iterate over all sub-elements   
        (entry/'*').each do |element|
          if element.name == "title"
            hash['title'] = element.content
          elsif element.name == "tableId"
            hash['table_id'] = element.content
          end
        end
        OpenStruct.new(hash)
      end
    end

    def query_opts( start_date, end_date, dimensions, metrics, filters=nil, max_results=nil, sort=nil )
      opts = {'ids' => "ga:#{@profile_id}",
              'start-date' => start_date,
              'end-date' => end_date,
              'dimensions' => dimensions.join(','),
              'metrics' => metrics.join(',')}
      opts['max-results'] = max_results if max_results
      opts['filters'] = filters unless filters.nil?
      opts['sort'] = sort unless sort.nil?
      opts
    end
   
  end

end

