module Api::V1
  class AuthenticationController < ApplicationController

    respond_to :json

    swagger_controller :login, 'Login'

    swagger_model :Identity do
      description 'Identity object.'
      property :auth_token, :string, :required, 'JWT authentication token'
      property :user, :User, :required, 'User object'
    end

    swagger_model :User do
      description 'A User object.'
      property :id, :integer, :required, 'User Id'
      property :email, :string, :required, "User's email"
      property :first_name, :string, :optional, "User's firstname"
      property :last_name, :string, :optional, "User's lastname"
    end

    swagger_api :authenticate_user do
      summary 'Returns the JWT authentication token'
      notes 'Notes...'
      param :query, :email, :string, :required, 'Email'
      param :query, :password, :string, :required, 'Password'
      response :ok, 'Success', :Identity
      response :unauthorized#, 'Unauthorized', :Error
      response :not_found
    end

    def authenticate_user
      user = User.find_for_database_authentication(email: params[:email])
      render json: {errors: ["User #{params[:email]} does not exist"]}, status: :not_found unless user
      if user.valid_password?(params[:password])
        render json: payload(user)
      else
        render json: {errors: ['Invalid Username/Password']}, status: :unauthorized
      end
    end

    private

    def payload(user)
      return nil unless user&.id
      {
        # TODO: check whether this constant is loaded
        auth_token: ::Api::ApiHelpers::JsonWebToken.encode({user_id: user.id}),
        user: user
      }
    end
  end
end
