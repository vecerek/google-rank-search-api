class HomeController < ApplicationController
  def index
    render json: { 'logged_in' => true }
  end
end
