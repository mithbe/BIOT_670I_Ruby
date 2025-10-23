class CreateDandelions < ActiveRecord::Migration[8.0]
  def change
    create_table :dandelions do |t|
      t.string :species
      t.string :location
      t.datetime :collected_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
