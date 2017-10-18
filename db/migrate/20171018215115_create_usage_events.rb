class CreateUsageEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :usage_events do |t|
      t.references :thing_id, foreign_key: true
      t.string :event_type, limit: 10

      t.timestamps
    end
    add_index :usage_events, :event_type
  end
end
