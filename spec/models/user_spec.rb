require "rails_helper"

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context "nameが存在しない時" do
    it "ユーザー作成に失敗する" do
      user = User.new(name: nil, email: "email@email.com", password: "yutoyuto")
      expect(user).to be_invalid
      expect(user.errors.details[:name][0][:error]).to eq :blank
      expect(user.errors.details[:email][0][:error]).to eq :taken
    end
  end

  context "同じnameが既に存在するとき" do
    it "ユーザー作成に失敗する" do
      User.create!(name: "uto", email: "gmail@email.com", password: "yutoyuto")
      user = User.new(name: "uto", email: "iga@email.com", password: "yutoyuto")
      expect(user).to be_invalid
      expect(user.errors.details[:name][0][:error]).to eq :taken
    end
  end

  # context "同じtitleが既に存在するとき" do
  #   it "記事作成に失敗する" do
  #     Article.create!(title: "uto" , body: "yutoyuto",user_id: 1)
  #     article = Article.new(title:"uto" , body: "yutoyuta" )
  #       expect(article).to be_invalid
  #       # binding.pry
  #       expect(article.errors.details[:title][0][:error]).to eq :taken
  #     end
  #   end

  context "user_idが存在しない時" do
    it "記事作成に失敗する" do
      article = Article.new(title: "uto", body: "yutoyuto", user_id: nil)
      # binding.pry
      # article = Article.new(title:"uto" , body: "yutoyuta" , user_id: nil)
      expect(article).to be_invalid
      # binding.pry
      expect(article.errors.details[:user_id][0][:error]).to eq :blank
      expect(article.errors.messages[:user]).to eq ["must exist"]
    end
  end

  context "user_idが存在しない時" do
    it "comment作成に失敗する" do
      comment = Comment.new(user_id: nil, article_id: 1)
      expect(comment).to be_invalid
      # binding.pry
      expect(comment.errors.details[:user_id][0][:error]).to eq :blank
      # expect(comment.errors.details[:article_id][0][:error]).to eq :blank
      # expect(comment.errors.messages[:user]).to eq ["must exist"]
      # expect(comment.errors.messages[:article]).to eq ["must exist"]
    end
  end
end
