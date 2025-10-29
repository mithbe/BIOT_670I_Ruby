class CreateJoinTableUserinfosDandelions < ActiveRecord::Migration[8.0]
  def change
    create_join_table :userinfos, :dandelions do |t|
      # t.index [:userinfo_id, :dandelion_id]
      # t.index [:dandelion_id, :userinfo_id]
    end
  end
end
