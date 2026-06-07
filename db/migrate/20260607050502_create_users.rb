class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :auth0_uid, null: false
      t.string :name

      t.timestamps
    end
    add_index :users, :auth0_uid, unique: true
    add_index :users, :email, unique: true
  end
end
