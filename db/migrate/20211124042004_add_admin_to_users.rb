class AddAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    # adminの値はデフォルトでnil(false)だから必ずしもfalseにする必要はない
      add_column :users, :admin, :boolean, default: false
  end
end
