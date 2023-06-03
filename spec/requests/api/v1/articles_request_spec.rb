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
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end


  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する場合" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }

      it "任意の記事の値が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
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


  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params) }

    let(:params) { { article: attributes_for(:article) } }
    # binding.pry
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

  describe " PATCH /articles" do
    subject{ patch(api_v1_article_path(article_id), params: params) }
    let(:params) { { article: { title: Faker::Lorem.word } } }
    let(:article_id) { article.id }
    let(:article) { create(:article,user: current_user) }

    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
    let(:current_user) { create(:user) }

    fit "記事のレコードを更新できる" do
      # subject
      # binding.pry
      expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                          not_change { article.reload.body }
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "Delete /articles" do
    subject{ delete(api_v1_article_path(article_id)) }

    let(:article_id) { article.id }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }
    let(:current_user) { create(:user) }

    context "自分が所持している記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }

      it "データを削除する" do
        expect { subject }.to change { Article.count }.by(-1)
        binding.pry
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分が所持していない記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) {create(:user)}
      it "データを削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)&
        change { Article.count }.by(0)
      end
    end

  end
end
