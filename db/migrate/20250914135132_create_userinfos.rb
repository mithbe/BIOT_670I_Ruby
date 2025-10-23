class CreateUserinfos < ActiveRecord::Migration[8.0]
  def change
    create_table :userinfos do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
