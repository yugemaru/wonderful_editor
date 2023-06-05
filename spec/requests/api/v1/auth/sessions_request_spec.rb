require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "情報が正しいとき" do
      # let(:params) { { session: { name: user.name, email: user.email, password: user.password } } }
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }
      let!(:user) { create(:user) }
      it "ログインできる" do
        subject
        # res = JSON.parse(response.body)
        expect(response.header["access-token"]).to be_present
        expect(response.header["client"]).to be_present
        expect(response.header["expiry"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "メールアドレスが正しくない時" do
      let(:params) { { session: { name: user.name, email: other_user.email, password: user.password } } }
      let!(:user) { create(:user) }
      let(:other_user) { create(:user) }
      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to eq ["Invalid login credentials. Please try again."]
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "Delete/session" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    let!(:headers) { user.create_new_auth_token }
    let(:user) { create(:user) }

    context "header情報が正しくて" do
      it "ログアウトできる" do
        subject
        expect(user.reload.tokens).to be_blank
        expect(response).to have_http_status(:ok)
        expect(is_logged_in?).to be_falsey
      end
    end

    context "header情報が誤っていて" do
      before {
        headers["access-token"] = "hoge"
        headers["expiry"] = "huga"
      }

      it "ログアウトに失敗する" do
        subject
        # binding.pry
        # res = JSON.parse(response.header)
        expect(headers["access-token"]).not_to be_blank
        expect(headers["expiry"]).not_to be_blank
        expect(headers["client"]).not_to be_blank
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
