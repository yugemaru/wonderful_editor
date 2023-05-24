require 'rails_helper'

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST/sign_in" do
    subject {post(api_v1_user_session_path, params: params)}

    context "情報が正しいとき" do
      let(:params){{session: {name: user.name, email:user.email, password:user.password }}}
      let!(:user){ create(:user)}
      it "ログインできる" do
        subject
        res = JSON.parse(response.body)
        binding.pry
        expect(res["data"]["name"]).to eq params[:session][:name]
        expect(res["data"]["email"]).to eq params[:session][:email]
        expect(response.header["access-token"]).to be_present
        expect(response.header["client"]).to be_present
        expect(response.header["expiry"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "メールアドレスが正しくない時" do
      let(:params){{session: {name: user.name, email:other_user.email, password:user.password }}}
      let!(:user){ create(:user)}
      let(:other_user){ create(:user) }
      fit "ログインできない"do
      subject
      binding.pry
        res = JSON.parse(response.body)
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
