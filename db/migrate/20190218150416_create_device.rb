class CreateDevice < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string :channel
      t.string :key
    end
  end
end
