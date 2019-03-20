module Api
  module V1
    module Measures
      class MeasurePresenter < SimpleDelegator

        attr_reader :measure, :duty_expression

        def initialize(measure, declarable, geo_areas = nil)
          super(measure)
          @measure = measure
          @duty_expression = Api::V1::Measures::DutyExpressionPresenter.new(measure, declarable)
          @geo_area = geo_areas&.last
        end

        def excise
          measure.excise?
        end

        def vat
          measure.vat?
        end

        def duty_expression_id
          duty_expression.id
        end

        def geographical_area
          @geo_area || measure.geographical_area
        end

        def geographical_area_id
          geographical_area.geographical_area_id
        end

        def additional_code
          measure.export_refund_nomenclature || measure.additional_code
        end

        def additional_code_id
          measure.export_refund_nomenclature_sid || measure.additional_code_sid
        end

      end
    end
  end
end