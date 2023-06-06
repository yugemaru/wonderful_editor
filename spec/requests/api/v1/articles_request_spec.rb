require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    context "記事作成のレコードが走ったとき" do
      let!(:article1) { create(:article,:published, updated_at: 1.days.ago) }
      let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
      let!(:article3) { create(:article, :published) }

      it "記事の一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 3
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "記事作成のレコードのstatusがdraftの時" do
      let!(:article) { create(:article,:draft) }

      it "記事の一覧が取得できない" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.length).to eq 0
      end
    end

  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する場合" do
      let(:article) { create(:article,:published) }
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
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    context "送信するヘッダー情報が正しくて" do
      let!(:headers) { current_user.create_new_auth_token }
      let(:current_user) { create(:user) }

      context "paramsも正しい時" do
        let(:params) { { article: attributes_for(:article,:published) } }

        it "記事のレコードが作成できる" do
          expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
          res = JSON.parse(response.body)
          expect(res["title"]).to eq params[:article][:title]
          expect(res["body"]).to eq params[:article][:body]
          expect(res["status"]).to eq params[:article][:status].to_s
          expect(response).to have_http_status(:ok)
        end
      end

      context "statusがdraftの時" do
        let(:params) { { article: attributes_for(:article,:draft)}}
        it "下書き状態" do
          expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
          res = JSON.parse(response.body)
          expect(res["status"]).to eq params[:article][:status].to_s
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end



  describe " PATCH /articles" do
    subject { patch(api_v1_article_path(article_id), params: params, headers: headers) }
    let!(:headers) { current_user.create_new_auth_token }
    let(:article_id) { article.id }
    let(:current_user) { create(:user) }

    context "titleを更新しようと思っていて" do
      let(:params) { { article: { title: Faker::Lorem.word }} }
      context "自分が所持している記事のレコードを更新しようとするとき" do
        let(:article) { create(:article, user: current_user) }
        it "記事のレコードを更新できる" do
          expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
          not_change { article.reload.body }
        end
      end

      context "自分が所持していない記事のレコードを更新しようとするとき" do
        let!(:article) { create(:article, user: other_user) }
        let(:other_user) { create(:user) }

        it "更新できない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "statusを変更しようと思っていて" do
      let(:params) { { article: { status: :published }} }
      context "自分が所持している記事のレコードを更新しようとするとき" do
        let(:article) { create(:article, user: current_user) }
        let(:current_user) { create(:user) }
        fit "記事のレコードを更新できる" do
          expect { subject }.to change { article.reload.status }.from(article.status).to(params[:article][:status].to_s) &
          not_change { article.reload.body }
        end
      end
    end

  end



  describe "Delete /articles" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    let!(:headers) { current_user.create_new_auth_token }
    let(:current_user) { create(:user) }
    let(:article_id) { article.id }

    context "自分が所持している記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }

      it "データを削除する" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分が所持していない記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }
      it "データを削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
