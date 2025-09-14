class AddIndexToUserinfoEmail < ActiveRecord::Migration[7.0]
  def change
    add_index :userinfos, :email, unique: true
  end
end