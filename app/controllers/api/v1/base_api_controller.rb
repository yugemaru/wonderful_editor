class Api::V1::BaseApiController < ApplicationController
  # def current_user
  #   @current_user ||= User.first
  # end
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_api_v1_user!
end
