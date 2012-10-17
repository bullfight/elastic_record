require 'helper'

class ElasticRecord::SearchesMany::ReflectionTest < ActiveSupport::TestCase
  # test "touch_column" do
  #   assert_nil reflection_class.new(Warehouse, :widgets, {}).touch_column
  #   assert_equal :updated_at, reflection_class.new(Warehouse, :widgets, touch: true).touch_column
  #   assert_equal :my_column, reflection_class.new(Warehouse, :widgets, touch: :my_column).touch_column
  # end
  # 
  # test "counter_cache_column" do
  #   assert_nil reflection_class.new(Warehouse, :widgets, {}).counter_cache_column
  #   assert_equal :widgets_count, reflection_class.new(Warehouse, :widgets, counter_cache: true).counter_cache_column
  #   assert_equal :my_column, reflection_class.new(Warehouse, :widgets, counter_cache: :my_column).counter_cache_column
  # end

  private
    def reflection_class
      ElasticRecord::SearchesMany::Reflection
    end
end
