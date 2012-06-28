class CreateGoodsNomenclatureDescriptions < ActiveRecord::Migration
  def change
    create_table :goods_nomenclature_descriptions do |t|
      t.integer :goods_nomenclature_description_period_sid
      t.string :language_id
      t.integer :goods_nomenclature_sid
      t.string :goods_nomenclature_item_id
      t.string :productline_suffix
      t.text :description

      t.timestamps
    end
  end
end