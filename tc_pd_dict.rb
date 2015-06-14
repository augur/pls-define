#!/usr/bin/env ruby
#encoding: utf-8

require_relative "pd_dict"
require "test/unit"

class TestPDDict < Test::Unit::TestCase
  
  def test_init
    assert_equal({"test" => nil}, PDDict.new("TEST").data)
    assert_equal({"test" => nil}, PDDict.new("test").data)
    File.open("st.json", "w+") {}
    assert_equal("st.json", PDDict.new("st.json").storage)
  end
  
  def test_init_raise
    assert_raise(ArgumentError) { (PDDict.new("nonexistent.json")) }
    assert_raise(ArgumentError) { (PDDict.new(".,:-")) }
    assert_raise(ArgumentError) { (PDDict.new("Кириллица")) }
    assert_raise(ArgumentError) { (PDDict.new(nil)) }
    assert_raise(ArgumentError) { (PDDict.new(125)) }
  end
  
end
