class CreateMetadatum < ActiveRecord::Migration[7.0]
  def change
    create_table :metadatum do |t|
      t.references :file_record, null: false, foreign_key: true  # link to the file
      t.string :key, null: false
      t.string :value
      t.string :data_type                                           # string, integer, boolean, date, etc.
      t.string :source                                              # which gem or method extracted
      t.jsonb :additional_json                                      # any nested/structured metadata (like EXIF)
      t.text :description                                           # optional: notes about the metadata
      t.string :category                                           # optional: logical grouping, e.g., "camera", "location", "file"

      t.timestamps
    end

    # Add indexes for faster lookups
    add_index :metadatum, [:file_record_id, :key], unique: true
    add_index :metadatum, :key
    add_index :metadatum, :category
  end
end

