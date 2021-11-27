class CreateMicroposts < ActiveRecord::Migration[6.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
    # add_indexを付与することにより並べ替え検索をしやすくできる
    # 両方を１つの配列に含めている.
    # Active Recordは、両方のキーを同時に扱う複合キーインデックスを作成する
end
end
