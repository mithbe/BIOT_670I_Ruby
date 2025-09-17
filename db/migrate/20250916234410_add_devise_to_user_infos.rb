# frozen_string_literal: true

class AddDeviseToUserInfos < ActiveRecord::Migration[7.0]
  def change
    change_table :userinfos, bulk: true do |t|
      ## Database authenticatable
      # t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at


      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip


      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable


      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at
    end

    # add_index :userinfos, :email,                unique: true
    add_index :userinfos, :reset_password_token, unique: true
    # add_index :userinfos, :confirmation_token,   unique: true
    # add_index :userinfos, :unlock_token,         unique: true
  end
end
