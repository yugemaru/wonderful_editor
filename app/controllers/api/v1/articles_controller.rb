class Api::V1::ArticlesController < ApplicationController

  before_action :set_article , only: %i[ show]

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles each_serializer: Api::V1::ArticlePreviewSerializer
    # binding.pry
  end

  def show
    article = Article.find(params[:id])
    render json: @article,serializer: Api::V1::ArticleSerializer
  end

  def create
    article = current_user.articles.create!(article_params)
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  private
  def set_article
    @article = Article.find(params[:id])
  end


  def article_params
    # binding.pry
    params.require(:article).permit(:title,:body)
  end
end
