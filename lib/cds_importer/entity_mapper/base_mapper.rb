class CdsImporter
  class EntityMapper
    class BaseMapper
      class << self
        attr_accessor :entity_class, :entity_mapping
      end

      NATIONAL = "N".freeze
      BASE_MAPPING = {
        "validityStartDate" => :validity_start_date,
        "validityEndDate" => :validity_end_date,
        "metainfo.origin" => :national,
        "metainfo.opType" => :operation,
        "metainfo.transactionDate" => :operation_date
      }.freeze

      def initialize(values)
        @values = values
      end

      def parse
        normalized_values = normalize(mapped_values)
        instance = entity_class.constantize.new
        instance.set_fields(normalized_values, entity_mapping.values)
      end

      protected

      def entity_class
        self.class.entity_class.presence || raise(ArgumentError.new("entity_class has not been defined: #{self.class}"))
      end

      def entity_mapping
        self.class.entity_mapping.presence || raise(ArgumentError.new("entity_mapping has not been defined: #{self.class}"))
      end

      def mapped_values
        entity_mapping.keys.inject({}) do |memo, key|
          mapped_key = entity_mapping.fetch(key)
          memo[mapped_key] = @values.dig(*key.split("."))
          memo
        end
      end

      def normalize(values)
        values[:national] = values[:national] == NATIONAL if values.key?(:national)
        values
      end
    end
  end
end
