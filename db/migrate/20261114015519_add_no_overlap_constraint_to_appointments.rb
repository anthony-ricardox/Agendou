class AddNoOverlapConstraintToAppointments < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    add_exclusion_constraint :appointments,
      "provider_id WITH =, tsrange(starts_at, ends_at) WITH &&",
      using: :gist,
      where: "status <> 2",
      name: "appointments_no_overlap"
  end
end
