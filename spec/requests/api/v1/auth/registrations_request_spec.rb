require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST / registrations" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "渡した情報が正しいとき" do
      let(:params) { attributes_for(:user) }

      it "ユーザーが作成される" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["data"]["name"]).to eq params[:name]
        expect(res["data"]["email"]).to eq params[:email]
        expect(response.header["access-token"]).to be_present
        expect(response.header["client"]).to be_present
        expect(response.header["expiry"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "渡した情報が正しくないとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "ユーザーが作成されない" do
        expect { subject }.to change { User.count }.by(0)
      end
    end
  end
end
