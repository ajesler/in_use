class CreateThings < ActiveRecord::Migration[5.0]
  def change
    create_table :things do |t|
      t.string :name
      t.text :description
      t.boolean :in_use

      t.timestamps
    end
  end
end
