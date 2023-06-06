# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :string           default("draft"), not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "記事の下書きが" do
    let(:article) { build(:article, user: user, status: :draft) }
    let(:user) { create(:user) }
    it "保存できる" do
      expect(article).to be_valid
      expect(article.status).to eq "draft"
    end
  end

  context "記事の公開が" do
    let(:article) { build(:article, user: user, status: :published) }
    let(:user) { create(:user) }
    it "保存できる" do
      expect(article).to be_valid
      expect(article.status).to eq "published"
    end
  end
end
