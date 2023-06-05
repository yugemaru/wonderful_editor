class Api::V1::ArticlesController < Api::V1::BaseApiController
  before_action :set_article, only: %i[show]
  skip_before_action :authenticate_api_v1_user!, only: %i[index show]

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: @article, serializer: Api::V1::ArticleSerializer
  end

  def create
    article = current_api_v1_user.articles.create!(article_params)
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def update
    article = current_api_v1_user.articles.find(params[:id])
    article.update!(article_params)
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def destroy
    article = current_api_v1_user.articles.find(params[:id])
    article.destroy!
    # render json: article, serializer: Api::V1::ArticleSerializer
  end

  private

    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :body)
    end
end
