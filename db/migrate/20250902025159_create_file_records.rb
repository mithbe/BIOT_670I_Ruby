class CreateFileRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :file_records do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :original_name
      t.string :file_type
      t.string :mime_type
      t.bigint :size
      t.text :description
      t.json :tags
      t.string :storage_path
      t.json :metadata

      t.timestamps
    end
  end
end
