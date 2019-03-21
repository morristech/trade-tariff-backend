module Api
  module V2
    module Changes
      class ChapterSerializer
        include FastJsonapi::ObjectSerializer
        set_id :goods_nomenclature_sid
        set_type :chapter
        attributes :description, :goods_nomenclature_item_id, :validity_start_date, :validity_end_date
      end
    end
  end
end