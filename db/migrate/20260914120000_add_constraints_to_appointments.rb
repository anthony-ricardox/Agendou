class AddConstraintsToAppointments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :appointments, :starts_at, false
    change_column_null :appointments, :ends_at, false
    change_column_null :appointments, :status, false
    change_column_default :appointments, :status, from: nil, to: 0
  end
end