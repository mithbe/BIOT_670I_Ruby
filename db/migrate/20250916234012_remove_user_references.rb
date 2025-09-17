class RemoveUserReferences < ActiveRecord::Migration[7.0]
  def change
    remove_reference :file_records, :user, foreign_key: true
    remove_reference :dandelions, :user, foreign_key: true
    remove_reference :file_uploads, :user, foreign_key: true
  end
end
