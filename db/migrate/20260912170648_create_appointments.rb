class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :service, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :status
      t.datetime :reminder_sent_at

      t.timestamps
    end
  end
end
