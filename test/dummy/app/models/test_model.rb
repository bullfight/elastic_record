module TestModel
  extend ActiveSupport::Concern

  included do
    include MockModel
    include ElasticRecord::Model
  end
end
