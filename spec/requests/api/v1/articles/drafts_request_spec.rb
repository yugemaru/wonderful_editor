require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }
  describe "GET /articles" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    context "記事作成のレコードが走ったとき" do
      let!(:article1) { create(:article, :draft, user: current_user) }
      let!(:article2) { create(:article, :draft, updated_at: 1.days.ago, user: current_user) }
      let!(:article3) { create(:article, :draft, updated_at: 2.days.ago, user: current_user) }

      it "記事の一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 3
        expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id, article3.id]
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        expect(res[0]["status"]).to eq "draft"
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定した id の記事が存在する場合" do
      let(:article) { create(:article, :draft, user: current_user) }
      let(:article_id) { article.id }

      it "任意の記事の値が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["status"]).to eq "draft"
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "指定した id の記事が存在しない場合" do
      let(:article_id) { 10000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
