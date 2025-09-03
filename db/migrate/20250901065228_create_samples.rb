class CreateSamples < ActiveRecord::Migration[8.0]
  def change
    create_table :samples do |t|
      t.string :name
      t.text :description
      t.string :image

      t.timestamps
    end
  end
end
