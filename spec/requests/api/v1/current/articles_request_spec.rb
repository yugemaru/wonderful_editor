require 'rails_helper'

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET current/articles" do
    subject{get(api_v1_current_articles_path, headers: headers)}
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }
      context "レコード作成された時" do
        let!(:article1) { create(:article, :published, user: current_user) }
        let!(:article2) { create(:article, :published, user: current_user) }
        fit "自分が書いた記事を取得できる" do
          subject
          res = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(res.map {|d| d["id"] }).to eq [article2.id, article1.id]
          expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
          expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end
end
