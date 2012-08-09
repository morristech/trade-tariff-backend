class Measure < Sequel::Model
  plugin :time_machine, period_start_column: :measures__validity_start_date,
                        period_end_column: :effective_end_date

  set_primary_key :measure_sid

  # rename to Declarable
  many_to_one :goods_nomenclature, key: :goods_nomenclature_sid,
                                   foreign_key: :goods_nomenclature_sid

  many_to_one :measure_type, key: :measure_type_id, dataset: -> {
    actual(MeasureType).where(measure_type_id: self[:measure_type])
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:measure_type] = nil}

    id_map = eo[:id_map]

    MeasureType.actual
               .eager(:measure_type_description)
               .where(measure_type_id: id_map.keys)
               .all do |measure_type|
      if measures = id_map[measure_type.measure_type_id]
        measures.each do |measure|
          measure.associations[:measure_type] = measure_type
        end
      end
    end
  end)

  one_to_many :measure_conditions, key: :measure_sid, dataset: -> {
    MeasureCondition.where(measure_sid: measure_sid)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:measure_conditions] = []}

    id_map = eo[:id_map]

    MeasureCondition.eager(:certificate,
                           {measurement_unit: :measurement_unit_description},
                           :monetary_unit,
                           :measure_condition_code,
                           :measure_condition_components,
                           :measure_action,
                           :measurement_unit_qualifier)
                    .where(measure_conditions__measure_sid: id_map.keys).all do |measure_condition|
      if measures = id_map[measure_condition.measure_sid]
        measures.each do |measure|
          measure.associations[:measure_conditions] << measure_condition
        end
      end
    end
  end)

  one_to_one :geographical_area, eager_loader_key: :geographical_area_sid, dataset: -> {
    actual(GeographicalArea).where(geographical_area_sid: geographical_area_sid)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:geographical_area] = nil}

    id_map = eo[:id_map]

    GeographicalArea.actual
                    .eager(:geographical_area_description,
                           :contained_geographical_areas)
                    .where(geographical_area_sid: id_map.keys)
                    .all do |geographical_area|
      if measures = id_map[geographical_area.geographical_area_sid]
        measures.each do |measure|
          measure.associations[:geographical_area] = geographical_area
        end
      end
    end
  end)


  many_to_many :excluded_geographical_areas, join_table: :measure_excluded_geographical_areas,
                                             left_key: :measure_sid,
                                             left_primary_key: :measure_sid,
                                             right_key: :excluded_geographical_area,
                                             right_primary_key: :geographical_area_id,
                                             class_name: 'GeographicalArea'

  many_to_many :footnotes, dataset: -> {
    actual(Footnote)
            .join(:footnote_association_measures, footnote_id: :footnote_id, footnote_type_id: :footnote_type_id)
            .where("footnote_association_measures.measure_sid = ?", measure_sid)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:footnotes] = []}

    id_map = eo[:id_map]

    Footnote.actual
            .eager(:footnote_description)
            .join(:footnote_association_measures, footnote_id: :footnote_id, footnote_type_id: :footnote_type_id)
            .where(footnote_association_measures__measure_sid: id_map.keys).all do |footnote|
      if measures = id_map[footnote[:measure_sid]]
        measures.each do |measure|
          measure.associations[:footnotes] << footnote
        end
      end
    end
  end)

  one_to_many :measure_components, key: :measure_sid, dataset: -> {
    MeasureComponent.where(measure_sid: measure_sid)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:measure_components] = []}

    id_map = eo[:id_map]

    MeasureComponent.eager(:duty_expression,
                           :measurement_unit,
                           :monetary_unit,
                           :measurement_unit_qualifier)
                    .where(measure_sid: id_map.keys).all do |measure_component|
      if measures = id_map[measure_component.measure_sid]
        measures.each do |measure|
          measure.associations[:measure_components] << measure_component
        end
      end
    end
  end)

  one_to_one :additional_code, key: :additional_code_sid, dataset: -> {
    actual(AdditionalCode).where(additional_code_sid: additional_code_sid)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:additional_code] = nil}

    id_map = eo[:id_map]

    AdditionalCode.actual.where(additional_code_sid: id_map.keys).all do |additional_code|
      if measures = id_map[additional_code.additional_code_sid]
        measures.each do |measure|
          measure.associations[:additional_code] = additional_code
        end
      end
    end
  end)

  one_to_one :quota_order_number, eager_loader_key: :ordernumber, dataset: -> {
    actual(QuotaOrderNumber).where(quota_order_number_id: ordernumber)
  }, eager_loader: (proc do |eo|
    eo[:rows].each{|measure| measure.associations[:quota_order_number] = nil}

    id_map = eo[:id_map]

    QuotaOrderNumber.actual
                    .eager(:quota_definition)
                    .where(quota_order_number_id: id_map.keys).all do |order_number|
      if measures = id_map[order_number.quota_order_number_id]
        measures.each do |measure|
          measure.associations[:quota_order_number] = order_number
        end
      end
    end
  end)

  def_column_alias :measure_type_id, :measure_type

  dataset_module do
    def with_base_regulations
      select(:measures.*).
      select_append(Sequel.as(:if.sql_function('measures.validity_end_date >= base_regulations.validity_end_date'.lit, 'base_regulations.validity_end_date'.lit, 'measures.validity_end_date'.lit), :effective_end_date)).
      join_table(:left, :base_regulations, base_regulations__base_regulation_id: :measures__measure_generating_regulation_id)
    end

    def with_modification_regulations
      select(:measures.*).
      select_append(Sequel.as(:if.sql_function('measures.validity_end_date >= modification_regulations.validity_end_date'.lit, 'modification_regulations.validity_end_date'.lit, 'measures.validity_end_date'.lit), :effective_end_date)).
      join_table(:left, :modification_regulations, modification_regulations__modification_regulation_id: :measures__measure_generating_regulation_id)
    end
  end

  def generating_regulation_present?
    measure_generating_regulation_id.present? && measure_generating_regulation_role.present?
  end

  def generating_regulation_code
    "#{measure_generating_regulation_id.first}#{measure_generating_regulation_id[3..6]}/#{measure_generating_regulation_id[1..2]}"
  end

  def generating_regulation_url
    year = measure_generating_regulation_id[1..2]
    # When we get to 2071 assume that we don't care about the 1900's
    # or the EU has a better way to search
    if year.to_i > 70
      full_year = "19#{year}"
    else
      full_year = "20#{year}"
    end
    code = "3#{full_year}#{measure_generating_regulation_id.first}#{measure_generating_regulation_id[3..6]}"
    "http://eur-lex.europa.eu/Result.do?code=#{code}&RechType=RECH_celex"
  end

  def origin
    "eu"
  end

  def import
    measure_type.trade_movement_code.in? MeasureType::IMPORT_MOVEMENT_CODES
  end

  def export
    measure_type.trade_movement_code.in? MeasureType::EXPORT_MOVEMENT_CODES
  end
end


