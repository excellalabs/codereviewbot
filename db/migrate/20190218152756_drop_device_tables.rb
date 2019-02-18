class DropDeviceTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :device_tables
  end
end
