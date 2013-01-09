module ElasticRecord
  module Model
    def self.included(base)
      base.class_eval do
        extend Searching
        extend ClassMethods
        include SearchesMany
      end
    end

    module ClassMethods
      def inherited(child)
        super

        if child < base_class
          child.elastic_index = elastic_index.dup
        end
      end

      def elastic_connection
        @elastic_connection ||= ElasticRecord::Connection.new(ElasticRecord::Config.servers)
      end

      def elastic_connection=(connection)
        @elastic_connection = connection
      end

      def elastic_relation
        ElasticRecord::Relation.new(self, arelastic)
      end

      def arelastic
        @arelastic ||= Arelastic::Builders::Search.new
      end

      def elastic_index
        @elastic_index ||= ElasticRecord::Index.new(self)
      end

      def elastic_index=(index)
        @elastic_index = index
      end
    end

    def arelastic
      self.class.arelastic
    end

    def elastic_index
      self.class.elastic_index
    end
  end
end
