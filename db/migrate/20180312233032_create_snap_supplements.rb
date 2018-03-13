class CreateSnapSupplements < ActiveRecord::Migration[5.1]
  def change
    create_table :snap_supplements do |t|

      t.timestamps
    end
  end
end
