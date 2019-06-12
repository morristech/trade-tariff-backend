module Api
  module V2
    module Commodities
      class SectionSerializer
        include FastJsonapi::ObjectSerializer

        set_type :section

        set_id :id

        attributes :numeral, :title, :position

        attribute :section_note, if: Proc.new { |section| section.section_note.present? } do |section|
          section.section_note.content
        end
      end
    end
  end
end
