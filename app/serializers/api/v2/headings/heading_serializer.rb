module Api
  module V2
    module Headings
      class HeadingSerializer
        include FastJsonapi::ObjectSerializer
        cache_options enabled: true, cache_length: 12.hours
        set_id :goods_nomenclature_sid
        set_type :heading

        attributes :goods_nomenclature_item_id, :description, :bti_url,
                   :formatted_description

        has_many :footnotes, serializer: Api::V2::Headings::FootnoteSerializer
        has_one :section, serializer: Api::V2::Headings::SectionSerializer
        has_one :chapter, serializer: Api::V2::Headings::ChapterSerializer
        has_many :commodities, serializer: Api::V2::Headings::CommoditySerializer

      end
    end
  end
end