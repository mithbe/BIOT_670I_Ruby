class FixUserinfos < ActiveRecord::Migration[7.1]
  def change
    # Add user_id if it doesn't exist
    unless column_exists?(:userinfos, :user_id)
      add_reference :userinfos, :user, null: false, foreign_key: true, index: { unique: true }
    end

    # Remove duplicate columns if they still exist
    if column_exists?(:userinfos, :email)
      remove_column :userinfos, :email, :string
    end
    if column_exists?(:userinfos, :name)
      remove_column :userinfos, :name, :string
    end
  end
end

