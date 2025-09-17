class ChangeMetadataFileReference < ActiveRecord::Migration[7.0]
  def change
    rename_column :metadata, :file_upload_id, :file_record_id
    add_foreign_key :metadata, :file_records
  end
end
