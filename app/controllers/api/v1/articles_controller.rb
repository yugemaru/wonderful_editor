class Api::V1::ArticlesController < Api::V1::BaseApiController
  before_action :set_article, only: %i[show]

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    # binding.pry
  end

  def show
    article = Article.find(params[:id])
    render json: @article, serializer: Api::V1::ArticleSerializer
  end

  def create
    article = current_user.articles.create!(article_params)
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def update
    article = current_user.articles.find(params[:id])
    article.update!(article_params)
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def destroy
    # binding.pry
    article = current_user.articles.find(params[:id])
    # binding.pry
    article.destroy!
    # binding.pry
    # render json: article, serializer: Api::V1::ArticleSerializer
    # binding.pry
  end

  private

    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      # binding.pry
      params.require(:article).permit(:title, :body)
    end
end
