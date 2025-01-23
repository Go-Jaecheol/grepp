class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_enum :user_role, %w[admin client]
    create_table :users do |t|
      t.string :name, null: false
      t.enum :role, enum_type: "user_role", default: "client", null: false

      t.timestamps
    end
  end
end
