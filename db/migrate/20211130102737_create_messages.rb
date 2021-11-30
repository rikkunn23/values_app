class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :from_id
      t.integer :to_id
      t.string :room_id

      t.timestamps
    end
  end
end
