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
    assert_raise(ArgumentError) { (PDDict.new("")) }
    assert_raise(ArgumentError) { (PDDict.new("nonexistent.json")) }
    assert_raise(ArgumentError) { (PDDict.new(".,:-")) }
    assert_raise(ArgumentError) { (PDDict.new("Кириллица")) }
    assert_raise(ArgumentError) { (PDDict.new(nil)) }
    assert_raise(ArgumentError) { (PDDict.new(125)) }
  end
  
  def test_add_def
    test_obj = PDDict.new("test")
    test_obj.add_definition("test", "!,some' ,45; definition")
    assert_equal({"test" => "!,some' ,45; definition", 
                  "some" => nil, "definition" => nil}, 
                 test_obj.data)
    
    test_obj.add_definition("some", "definition!!123 test-'`;")
    assert_equal({"test" => "!,some' ,45; definition", 
                  "some" => "definition!!123 test-'`;", "definition" => nil}, 
                 test_obj.data)
    
    test_obj.add_definition("definition", "1999")
    assert_equal({"test" => "!,some' ,45; definition", 
                  "some" => "definition!!123 test-'`;", "definition" => "1999"}, 
                 test_obj.data)
    
    #check tabs and newlines in definition
    test_obj = PDDict.new("test")
    test_obj.add_definition("test", "test \tsome \r\ndefinition")
    assert_equal({"test" => "test \tsome \r\ndefinition", 
                  "some" => nil, "definition" => nil}, 
                 test_obj.data)
  end
  
  def test_add_def_raise
    assert_raise(ArgumentError) {
      test_obj = PDDict.new("test")      
      test_obj.add_definition("some", "test")
    }
      
    assert_raise(ArgumentError) {
      test_obj = PDDict.new("test")
      test_obj.add_definition("some", 42)
    }
    
    assert_raise(ArgumentError) {
      test_obj = PDDict.new("test")
      test_obj.add_definition("some", "explanation")
      test_obj.add_definition("some", "another one")
    }
  end
end
