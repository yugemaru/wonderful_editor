require "rails_helper"

RSpec.describe Article, type: :model do
  context "記事の下書きが" do
    let(:article) { build(:article, user: user, status: 0) }
    let(:user) { create(:user) }
    it "保存できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "記事の公開が" do
    let(:article) { build(:article, user: user, status: 1) }
    let(:user) { create(:user) }
    it "保存できる" do
      expect(article).to be_valid
      expect(article.status).to eq "published"
    end
  end
end
