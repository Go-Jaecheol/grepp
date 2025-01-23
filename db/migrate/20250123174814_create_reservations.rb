class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_enum :reservation_status, %w[pending confirmed canceled]
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :headcount, null: false
      t.enum :status, enum_type: "reservation_status", default: "pending", null: false

      t.timestamps
    end
  end
end
