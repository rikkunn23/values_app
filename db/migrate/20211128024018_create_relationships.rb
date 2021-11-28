class CreateRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true
    # カラムに一意性制約をかける
    # 2つの組み合わせが必ずユニークであることを保証
    # ユーザーが同じユーザーを2回以上フォローすることを防ぎます
  end
end
