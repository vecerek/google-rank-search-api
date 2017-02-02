class CreateRankSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :rank_searches do |t|
      t.references :user
      t.string :domain
      t.string :keyword
      t.integer :ranking

      t.timestamps
    end

    add_index :rank_searches, :domain
    add_index :rank_searches, :keyword
    add_index :rank_searches, :ranking
  end
end
