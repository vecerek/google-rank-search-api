module Api::V1
  class SearchController < ApiController
    before_action :check_params!

    respond_to :json

    swagger_controller :search, 'Search'

    swagger_model :Search do
      description 'Google Rank Search  object.'
      property :domain, :string, :required, 'Searched domain'
      property :keyword, :string, :required, 'Searched keyword'
      property :ranking, :integer, :optional, 'Google ranking of the searched term'
      property :result, :Result, :optional, 'Google result of the searched term'
    end

    swagger_model :Result do
      description 'Google search result object.'
      property :title, :string, :required, ''
      property :htmlTitle, :string, :required, ''
      property :link, :string, :required, ''
      property :displayLink, :string, :required, ''
      property :snippet, :string, :optional, ''
      property :htmlSnippet, :string, :optional, ''
      property :formattedUrl, :string, :optional, ''
      property :htmlFormattedUrl, :string, :optional, ''
      property :pagemap, :Pagemap, :optional, ''
    end

    swagger_model :Pagemap do
      description ''
      property :cse_thumbnail, :CseThumbnail, :optional, ''
      property :metatags, :Metatags, :required, ''
      property :cse_image, :CseImage, :optional, ''
    end

    swagger_model :CseThumbnail do
      description ''
      property :width, :string, :required, ''
      property :height, :string, :required, ''
      property :src, :string, :required, ''
    end

    swagger_model :Metatags do
      description ''
      property :viewport, :string, :required, ''
      property :author, :string, :optional, ''
    end

    swagger_model :CseImage do
      property :src, :string, :required, ''
    end

    swagger_api :index do
      summary 'Returns the Google search position of a given keyword for a given domain.'
      notes 'Notes...'
      param :query, :domain, :string, :required, 'The searched domain name, e.g.: example.com'
      param :query, :keyword, :string, :required, 'The searched keyword'
      param :query, :limit, :integer, :optional, 'Number of google result pages to scrape',
            default_value: DEFAULT_SEARCH_LIMIT
      response :ok, 'Success', :Search
    end

    # GET /v1/search?domain=&keyword=&limit=
    def index
      limit = params[:limit].to_i || DEFAULT_SEARCH_LIMIT
      ranking, result = Api::ApiHelpers::GoogleCustomSearch.find_ranking(params[:domain], params[:keyword], limit)
      RankSearch.create(user: @current_user, domain: params[:domain], keyword: params[:keyword], ranking: ranking)
      render json: rank_search(ranking, result)
    end

    private

    DEFAULT_SEARCH_LIMIT = 1

    def check_params!
      errors = []
      %i(domain keyword).each { |param| errors << "Missing parameter: #{param}" unless params[param] }
      render json: { errors: errors }, status: :forbidden unless errors.empty?
      params.permit(:domain, :keyword, :limit)
    end

    def rank_search(ranking, result)
      {
        :domain  => params[:domain],
        :keyword => params[:keyword],
        :ranking => ranking,
        :result  => result.as_json(except: [:kind, :cacheId])
      }
    end
  end
end
