class CreateDeviceTable < ActiveRecord::Migration[5.2]
  def change
    create_table :device_tables do |t|
      t.string :channel
      t.string :key
    end
  end
end
