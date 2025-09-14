class AddFieldsToUserinfo < ActiveRecord::Migration[8.0]
  def change
    add_column :userinfos, :first_name, :string
    add_column :userinfos, :last_name, :string
    add_column :userinfos, :address, :string
    add_column :userinfos, :city, :string
    add_column :userinfos, :state, :string
    add_column :userinfos, :zip_code, :string
  end
end
