class ApplicationController < ActionController::Base
  include ActionController::Serialization

  #protect_from_forgery with: :exception
  attr_reader :current_user

  protected
  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[:user_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Not Authenticated'] }, status: :unauthorized
  end

  private
  def http_token
    @http_token ||= if request.headers['Authorization'].present?
                      request.headers['Authorization'].split(' ').last
                    end
  end

  def auth_token
    #TODO: check whether this constant is loaded
    @auth_token ||= Api::ApiHelpers::JsonWebToken.decode(http_token)
  end

  def user_id_in_token?
    http_token && auth_token && auth_token[:user_id].to_i
  end

  class << self
    Swagger::Docs::Generator::set_real_methods

    def inherited(subclass)
      super
      subclass.class_eval do
        setup_basic_api_documentation
      end
   end

   private

   def setup_basic_api_documentation
     #swagger_model :Error do
     #  description 'Error response object.'
     #  property :errors, :array, :required, 'Array of errors'
     #end

      [:index, :show, :create, :update, :delete].each do |api_action|
        swagger_api api_action do
          param :header, 'Authorization', :string, :required, "Bearer jwt_auth_token_here"
          response :unauthorized#, 'Unauthorized', :Error
        end
      end
    end
  end
end
