module Api
  module V2
    module Headings
      class GuideSerializer
        include FastJsonapi::ObjectSerializer
        set_type :guide
        attributes :title, :url
      end
    end
  end
end