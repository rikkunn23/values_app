class AddIndexToUsersEmail < ActiveRecord::Migration[6.1]
  def change
    #dbにindexを張る ユニーク制約で既に入っている値と同じ値は入れられなくなる
    add_index :users, :email, unique: true
  end
end
