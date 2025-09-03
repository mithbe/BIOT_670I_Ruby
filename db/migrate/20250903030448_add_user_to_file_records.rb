class AddUserToFileRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :file_records, :user, null: false, foreign_key: true
  end
end
