#!/usr/bin/env ruby
# encoding: utf-8


unless $:.include?('.')
  added = true
  $: << '.'
end
#Can't use require_relative cause of circular reference errors within pd_stat_view
require "pd_stat_view"
require "pd_dict"
require "pd_source"
$:.delete('.') if added

require "test/unit"

class TestPDStatView < Test::Unit::TestCase
  
  def test_init_rase
    assert_raise(RuntimeError) {
      PDStatView.new("/localunknown/path")
    }
    
    assert_raise(RuntimeError) {
      PDStatView.new("http://www.unknownaddressss/1.dmp")
    }
  end
  
  TMP = 'tc_pd_stat_view_dump.json'
    
  def test_stat_methods
    d = PDDict.new("one")
    d.add_definition("one", "two three")
    d.add_definition("two", "three")
    d.add_definition("three", "four")
    d.add_definition("four", NO_DEF)
    #get processed NO_DEF form and define it
    d.add_definition(d.request_definition, NO_DEF)
    d.save(TMP)
    
    v = PDStatView.new(TMP)
    assert(v.self_consistent?)
    assert_equal(5, v.get_count)
    assert_equal([["three",2]], v.get_top_refs(1))
    assert_equal("four", v.get_no_def[0])
    assert_equal("two", v.get_word(1))
    
    File.delete(TMP)
  end
  
  
end
