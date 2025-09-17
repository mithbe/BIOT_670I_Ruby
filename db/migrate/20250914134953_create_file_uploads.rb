class CreateFileUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :file_uploads do |t|
      t.string :filename
      t.string :filetype
      t.references :user, null: false, foreign_key: true
      t.references :dandelion, null: false, foreign_key: true
      t.timestamps
    end
  end
end
