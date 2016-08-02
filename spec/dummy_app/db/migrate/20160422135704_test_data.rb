class TestData < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.boolean :moderator, default: false
    end

    create_table :articles do |t|
      t.string :title
      t.integer :user_id

      t.timestamps
    end

    create_table :comments do |t|
      t.string :body
      t.integer :article_id

      t.timestamps
    end

    create_table :moderations do |t|
      t.integer :user_id
      t.integer :article_id

      t.timestamps
    end
  end
end
