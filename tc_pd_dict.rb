#!/usr/bin/env ruby
#encoding: utf-8

require_relative "pd_dict"
require "test/unit"

class TestPDDict < Test::Unit::TestCase

  def test_init
    assert_equal({"test" => nil}, PDDict.new("TEST").data)
    assert_equal({"test" => nil}, PDDict.new("test").data)
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
    assert_equal({"some" => 1, "definition" => 1},
                test_obj.ref_stat)
    
    test_obj.add_definition("some", "definition!!123 test-'`;")
    assert_equal({"test" => "!,some' ,45; definition", 
                  "some" => "definition!!123 test-'`;", "definition" => nil}, 
                 test_obj.data)
    assert_equal({"some" => 1, "definition" => 2, "test" => 1},
                test_obj.ref_stat)
    
    test_obj.add_definition("definition", "1999")
    assert_equal({"test" => "!,some' ,45; definition", 
                  "some" => "definition!!123 test-'`;", "definition" => "1999"}, 
                 test_obj.data)
    
    #Check reference count statistics more deeply
    #Multiple references in definition should be counted as 1
    test_obj = PDDict.new("test")
    test_obj.add_definition("test", "some definition")
    test_obj.add_definition("definition", "some some definition")
    test_obj.add_definition("some", "test definition")
    assert_equal({"test" => 1, "some" => 2, "definition" => 2},
                  test_obj.ref_stat)
    
    #check tabs and newlines in definition
    test_obj = PDDict.new("test")
    test_obj.add_definition("test", "test \tsome \r\ndefinition")
    assert_equal({"test" => "test \tsome \r\ndefinition", 
                  "some" => nil, "definition" => nil}, 
                 test_obj.data)
  end

  
  def test_req_def 
    test_obj = PDDict.new("test")
    assert_equal("test", test_obj.request_definition)
    
    test_obj = PDDict.new("test")
    word = test_obj.request_definition
    test_obj.add_definition(word, "some test some definition stuff")
    assert_equal("some", test_obj.request_definition)
    test_obj.add_definition("some", "test")
    assert_equal("definition", test_obj.request_definition)
    test_obj.add_definition("definition", "test")
    assert_equal("stuff", test_obj.request_definition)
    test_obj.add_definition("stuff", "test")
    assert_equal(nil, test_obj.request_definition)    
  end

  
  def test_save_load
    p = PDDict.new("test")
    w = p.request_definition
    p.add_definition(w, "some test definition stuff")
    p.save('dump.json')
    
    p2 = PDDict.new('dump.json')

    assert_equal(p.data, p2.data)
    assert_equal(p.ref_stat, p2.ref_stat)
    assert_equal(p.storage, p2.storage)
    
    File.delete('dump.json')
  end

  
  def test_save_raise
    assert_raise(TypeError) {
      p = PDDict.new("test")
      p.save
    }
    
    assert_raise(ArgumentError) {
      p = PDDict.new("test")
      p.save 42
    }

    assert_raise(Errno::EACCES) {
      p = PDDict.new("test")
      p.save '//\\'
    }
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
