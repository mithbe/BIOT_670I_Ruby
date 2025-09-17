class CopyFileUploadsDataRailsFriendly < ActiveRecord::Migration[7.0]
  def up
    # Get all records from file_uploads
    uploads = FileUpload.all

    # Prepare data for insertion into file_records
    data = uploads.map do |upload|
      {
        id: upload.id,
        dandelion_id: upload.dandelion_id,
        userinfo_id: upload.userinfo_id,
        filename: upload.filename,
        upload_type: upload.file_type,  # map old column to new one
        created_at: upload.created_at,
        updated_at: upload.updated_at
      }
    end

    # Insert all at once
    FileRecord.insert_all(data) unless data.empty?
  end

  def down
    # Remove all records that were copied
    FileRecord.where(id: FileUpload.pluck(:id)).delete_all
  end
end
