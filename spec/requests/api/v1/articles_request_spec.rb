require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "記事の一覧が取得できる1" do
      subject
      res = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
    end

    it "記事の一覧が取得できる2" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
    end

    it "記事の一覧が取得できる3" do
      subject
      res = JSON.parse(response.body)
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
    end

    it "記事の一覧が取得できる4" do
      subject
      res = JSON.parse(response.body)
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
    end

    it "記事の一覧が取得できる5" do
      subject
      res = JSON.parse(response.body)
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end


  
  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }

    # stub
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    it "記事のレコードが作成できる" do
      expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
      res = JSON.parse(response.body)
      expect(res["title"]).to eq params[:article][:title]
      expect(res["body"]).to eq params[:article][:body]
      expect(response).to have_http_status(:ok)
    end
  end
end
