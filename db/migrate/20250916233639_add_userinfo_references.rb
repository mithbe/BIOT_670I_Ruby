class AddUserinfoReferences < ActiveRecord::Migration[7.0]
  def change
    # Add new foreign key columns
    add_reference :file_records, :userinfo, foreign_key: true
    add_reference :dandelions, :userinfo, foreign_key: true
    add_reference :file_uploads, :userinfo, foreign_key: true
  end
end
