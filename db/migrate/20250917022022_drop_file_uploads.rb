class DropFileUploads < ActiveRecord::Migration[7.0]
  def up
    execute "DROP TABLE file_uploads CASCADE;"
  end

  def down
    # Optional: recreate the table if you want rollback
    create_table :file_uploads do |t|
      t.references :dandelion, null: false, foreign_key: true
      t.references :userinfo, null: false, foreign_key: true
      t.string :filename
      t.string :upload_type
      t.timestamps
    end
  end
end


