require 'elastic_record/relation/value_methods'
require 'elastic_record/relation/batches'
require 'elastic_record/relation/calculations'
require 'elastic_record/relation/delegation'
require 'elastic_record/relation/finder_methods'
require 'elastic_record/relation/hits'
require 'elastic_record/relation/merging'
require 'elastic_record/relation/none'
require 'elastic_record/relation/search_methods'

module ElasticRecord
  class Relation
    include Batches, Calculations, Delegation, FinderMethods, Hits, Merging, SearchMethods

    attr_reader :klass, :values

    def initialize(klass, values: {})
      @klass = klass
      @values = values
    end

    def initialize_copy(other)
      @values = @values.dup
      reset
    end

    def becomes(klass)
      became = klass.allocate
      became.instance_variable_set(:@klass, @klass)
      became.instance_variable_set(:@values, @values.dup)
      became
    end

    def metamorphose(new_klass)
      result = self.class.new(new_klass, values: values.dup)
      result.safe! if safe?
      result
    end

    def count
      search_hits.total
    end

    def exists?(*args)
      (args.empty? ? self : filter(*args)).count > 0
    end

    def aggregations
      @aggregations ||= begin
        results = search_results['aggregations']
        ElasticRecord::AggregationResponse::Builder.extract(results)
      end
    end

    def explain(id)
      klass.elastic_index.explain(id, as_elastic)
    end

    def to_a
      @records ||= find_hits(search_hits)
    end

    def safe!
      @safe = true
    end

    def safe?
      @safe
    end

    def find_hits(search_hits)
      if klass.elastic_index.load_from_source
        search_hits.hits.map { |hit| klass.from_search_hit(hit) }
      else
        ids = search_hits.to_ids
        if safe?
          klass.where(id: ids).to_a.sort_by { |doc| ids.index { |i| i.to_s == doc.id.to_s } }
        else
          klass.find ids
        end
      end
    end

    def delete_all
      find_ids_in_batches { |ids| klass.delete(ids) }
      klass.elastic_index.delete_by_query(as_elastic)
    end

    def ==(other)
      to_a == other
    end

    def inspect
      to_a.inspect
    end

    def scoping
      previous, klass.current_elastic_search = klass.current_elastic_search, self
      yield
    ensure
      klass.current_elastic_search = previous
    end

    private

      def reset
        @search_results = @records = nil
      end

  end
end
