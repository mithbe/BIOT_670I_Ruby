class ChangeFileRecordsColumnsToJsonbV2 < ActiveRecord::Migration[8.0]
  def up
    change_column :file_records, :tags, :jsonb, using: 'tags::jsonb'
    change_column :file_records, :metadata, :jsonb, using: 'metadata::jsonb'
  end

  def down
    change_column :file_records, :tags, :json, using: 'tags::json'
    change_column :file_records, :metadata, :json, using: 'metadata::json'
  end
end

