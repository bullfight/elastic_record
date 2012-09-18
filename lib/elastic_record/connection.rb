require 'net/http'

module ElasticRecord
  class Connection
    # :timeout: 10
    # :retries: 2
    # :auto_discovery: false

    attr_accessor :servers, :options
    attr_accessor :request_count, :current_server
    def initialize(servers, options = {})
      if servers.is_a?(Array)
        self.servers = servers
      else
        self.servers = servers.split(',')
      end

      self.current_server = choose_server
      self.request_count = 0
      self.options = options
    end

    def head(path)
      http_request(:head, path).code
    end

    def json_get(path, json = nil)
      json_request :get, path, json
    end

    def json_post(path, json = nil)
      json_request :post, path, json
    end

    def json_put(path, json = nil)
      json_request :put, path, json
    end

    def json_delete(path, json = nil)
      json_request :delete, path, json
    end

    def json_request(method, path, json)
      body = json.is_a?(Hash) ? ActiveSupport::JSON.encode(json) : json
      response = http_request(method, path, body)

      json = ActiveSupport::JSON.decode response.body
      raise json['error'] if json['error']

      json
    end

    METHODS = {
      head: Net::HTTP::Head,
      get: Net::HTTP::Get,
      post: Net::HTTP::Post,
      put: Net::HTTP::Put,
      delete: Net::HTTP::Delete
    }

    def http_request(method, path, body = nil)
      request = METHODS[method].new(path)
      request.body = body

      ActiveSupport::Notifications.instrument("request.elastic_record") do |payload|
        payload[:method]      = method
        payload[:request_uri] = path
        payload[:response]    = http.request(request)
      end
    end

    private
      def choose_server
        servers.sample
      end

      def http
        self.request_count += 1

        if request_count > 100
          self.current_server = choose_server
          self.request_count = 0
        end

        host, port = current_server.split ':'

        http = Net::HTTP.new(host, port)
        if options[:timeout]
          http.read_timeout = options[:timeout].to_i
        end
        http
      end
  end
end