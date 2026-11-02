class AddProviderToAppointments < ActiveRecord::Migration[8.1]
  def up
    add_reference :appointments, :provider, foreign_key: true

    execute <<~SQL
      UPDATE appointments
      SET provider_id = services.provider_id
      FROM services
      WHERE services.id = appointments.service_id
    SQL

    change_column_null :appointments, :provider_id, false
  end

  def down
    remove_reference :appointments, :provider, foreign_key: true
  end
end
