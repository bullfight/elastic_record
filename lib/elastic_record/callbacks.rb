module ElasticRecord
  module Callbacks
    def self.included(base)
      return unless base.respond_to?(:after_save) &&  base.respond_to?(:after_destroy)

      base.class_eval do
        after_save if: :changed? do
          self.class.elastic_index.index_record self
        end

        after_destroy do
          self.class.elastic_index.delete_document id
        end
      end
    end


    def as_search
      json = {}

      elastic_index.mapping[:properties].each do |field, mapping|
        value = try field
        next if value.nil?

        search_value = case mapping[:type]
          when :object
            value.as_search
          when :nested
            value.map(&:as_search)
          else
            value
          end

        if value.present? || value == false
          json[field] = search_value
        end
      end

      amend_as_search(json) if respond_to?(:amend_as_search)

      json
    end
  end
end
