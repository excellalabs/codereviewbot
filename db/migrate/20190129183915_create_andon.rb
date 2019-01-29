class CreateAndon < ActiveRecord::Migration[5.2]
  def change
    create_table :andons do |t|
      t.string :channel
      t.string :issue
      t.timestamps
    end
  end
end
