# db/migrate/20250930190000_create_upload_batches.rb
class CreateUploadBatches < ActiveRecord::Migration[7.0]
  def change
    create_table :upload_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.json :files, null: false, default: []
      t.string :status, null: false, default: "uploaded"
      t.datetime :expires_at
      t.timestamps
    end
  end
end
