class DropMetadataTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :metadata, if_exists: true
  end
end
