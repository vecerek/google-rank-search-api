module Api::V1
  class ApiController < ApplicationController
    before_action :authenticate_request!

    # Generic API stuff here
  end
end
