require 'net/http'
require 'json'

module Api::ApiHelpers
  class GoogleCustomSearch
    attr_reader :q, :limit

    def self.find_ranking(domain, keyword, limit)
      GoogleCustomSearch.new(keyword, domain, limit).build.result
    end

    def initialize(q, domain, limit)
      @q = q
      @domain = domain
      @limit = limit * RESULTS_PER_PAGE
      @ranking = INITIAL_RANKING
    end

    def build
      params = {
          :q => @q,
          :cx => ENV['SEARCH_ENGINE_ID'],
          :num => RESULTS_PER_PAGE,
          :start => @start || START_INDEX,
          :key => ENV['CUSTOM_SEARCH_API_KEY']
      }.to_query
      @uri = URI(BASE_URI + params)
      self
    end

    def result
      return @ranking, @result if @ranking.present? && @result.present?
      @page = next_page
      while next? && !found?
        @start = @page.queries.nextPage[0].startIndex
        build
        @page = next_page
      end
      @ranking = nil unless @result
      return @ranking, @result
    end

    private

    BASE_URI = 'https://www.googleapis.com/customsearch/v1?'
    RESULTS_PER_PAGE = 10
    DEFAULT_LIMIT = RESULTS_PER_PAGE
    START_INDEX = 1
    INITIAL_RANKING = 0

    def next?
      @ranking < @limit
    end

    def found?
      @result = @page.items.find { |item| @ranking += 1; item.link =~ /#{@domain}/ }
    end

    def next_page
      response = Net::HTTP.get_response(@uri)
      case response.code.to_i
        when 200
          JSON.parse(response.body, object_class: CustomOpenStruct)
        when 403
          raise Exceptions::LimitReachedError
        else
          raise Exceptions::UnknownError
      end
    end
  end

  class CustomOpenStruct < OpenStruct
    def as_json(options = nil)
      @table.as_json(options)
    end
  end
end
