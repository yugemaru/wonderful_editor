class ChangeColumnDefaultStatusOfArticles < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:articles, :status, "draft")
  end
end
