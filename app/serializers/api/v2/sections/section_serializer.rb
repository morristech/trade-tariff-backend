module Api
  module V2
    module Sections
      class SectionSerializer
        include FastJsonapi::ObjectSerializer
        attributes :id, :numeral, :title, :position, :chapter_from, :chapter_to
        set_type :section
        attribute :section_note, if: Proc.new { |section| section.section_note.present? } do |section|
          section.section_note.content
        end
        has_many :chapters, serializer: Api::V2::Sections::ChapterSerializer
      end
    end
  end
end
