class Api::V1::Auth::SessionsController < DeviseTokenAuth::SessionsController
  before_action :authenticate_api_v1_user!

  # def create
  #   binding.pry
  #   render json: {
  #     data: {
  #       "access-token": "wwwww",
  #     }
  #   }, status: 200
  #     render :new, status: :unprocessable_entity
  # end

end
