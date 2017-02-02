module Api::V1
  class UsersController < ApiController
    respond_to :json

    swagger_controller :users, 'Users'

    swagger_model :User do
      description 'A User object.'
      property :id, :integer, :required, 'User Id'
      property :email, :string, :required, "User's email"
      property :first_name, :string, :optional, "User's firstname"
      property :last_name, :string, :optional, "User's lastname"
    end

    swagger_api :show do
      summary 'Fetches a single User item'
      notes 'Notes...'
      param :path, :id, :integer, :required, 'User Id'
      response :ok, 'Success', :User
    end

    # GET /v1/users/:id
    def show
      @user = User.find(params[:id])
      render json: @user, status: :ok
    end

    # POST /v1/users/new
    def create
      @user = User.new({
        :email                 => params[:email],
        :first_name            => params[:first_name],
        :last_name             => params[:last_name],
        :password              => params[:password],
        :password_confirmation => params[:password_confirmation]
       })
      if @user.save
        render json: @user, status: :ok
      else
        render json: {errors: missing_create_params}, status: :unprocessable_entity
      end
    end

    private

    def missing_create_params
      %i(email password password_confirmation).map do |param|
        "Missing required param #{param}" unless params[param]
      end
    end
  end
end
