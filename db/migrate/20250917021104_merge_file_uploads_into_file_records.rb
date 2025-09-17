class MergeFileUploadsIntoFileRecords < ActiveRecord::Migration[7.0]
  def change
    # Add any missing columns from file_uploads to file_records
    # Example:
    add_column :file_records, :dandelion_id, :bigint unless column_exists?(:file_records, :dandelion_id)
    add_column :file_records, :userinfo_id, :bigint unless column_exists?(:file_records, :userinfo_id)
    add_column :file_records, :filename, :string unless column_exists?(:file_records, :filename)
    add_column :file_records, :file_type, :string unless column_exists?(:file_records, :file_type)

    # Add foreign keys
    add_foreign_key :file_records, :dandelions unless foreign_key_exists?(:file_records, :dandelions)
    add_foreign_key :file_records, :userinfos unless foreign_key_exists?(:file_records, :userinfos)
  end
end

