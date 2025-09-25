class CreateMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata do |t|
      t.string :key
      t.string :value
      t.references :file_upload, null: false, foreign_key: true

      t.timestamps
    end
  end
end
