class RenameFileTypeInFileRecords < ActiveRecord::Migration[7.0]
  def change
    rename_column :file_records, :file_type, :upload_type
  end
end
