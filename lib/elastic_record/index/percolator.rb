module ElasticRecord
  class Index
    module Percolator
      def create_percolator(name, elastic_query)
        p "creating #{elastic_query.inspect}"
        unless exists? percolator_index_name
          create percolator_index_name
        else
          update_mapping percolator_index_name
        end

        connection.json_put "/_percolator/#{percolator_index_name}/#{name}", elastic_query
      end

      def delete_percolator(name)
        connection.json_delete "/_percolator/#{percolator_index_name}/#{name}"
      end

      def percolator_exists?(name)
        connection.json_get("/_percolator/#{percolator_index_name}/#{name}")['exists']
      end

      def percolate(document)
        # p "document = #{document}"
        connection.json_get("/#{percolator_index_name}/#{type}/_percolate", 'doc' => document)['matches']
      end

      def reset_percolator
        delete(percolator_index_name) if exists?(percolator_index_name)
      end

      def percolator_index_name
        @percolator_index_name ||= "percolate_#{alias_name}"
      end
    end
  end
end