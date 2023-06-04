class Api::V1::Auth::SessionsController < DeviseTokenAuth::SessionsController
  # skip_before_action :verify_authenticity_token

  private

    def resource_params
      # binding.pry
      params.require(:session).permit(:name, :email, :password)
    end
end
