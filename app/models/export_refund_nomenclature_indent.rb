class ExportRefundNomenclatureIndent < ActiveRecord::Base
  self.primary_keys =  :export_refund_nomenclature_indents_sid

  belongs_to :export_refund_nomenclature, foreign_key: :export_refund_nomenclature_sid
end

# == Schema Information
#
# Table name: export_refund_nomenclature_indents
#
#  record_code                               :string(255)
#  subrecord_code                            :string(255)
#  record_sequence_number                    :string(255)
#  export_refund_nomenclature_indents_sid    :string(255)
#  export_refund_nomenclature_sid            :string(255)
#  validity_start_date                       :date
#  number_export_refund_nomenclature_indents :string(255)
#  goods_nomenclature_item_id                :string(255)
#  additional_code_type                      :integer(4)
#  export_refund_code                        :string(255)
#  productline_suffix                        :string(255)
#  created_at                                :datetime
#  updated_at                                :datetime
#
