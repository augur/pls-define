#!/usr/bin/env ruby
# encoding: utf-8

require_relative "pd_stat_view"
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
  
end
