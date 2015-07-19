#!/usr/bin/env ruby
# encoding: utf-8

require_relative "pd_source"
require "test/unit"

class TestPDSource < Test::Unit::TestCase
  
  def test_web_source
    extend PDSourceWeb
    #Correction
    assert_equal("orange", get_definition("oranges"))        
    #Case insensitivty
    assert_equal("orange", get_definition("oRaNgEs"))
    #HTTP Redirection
    assert_equal("function", get_definition("functions"))
    #Actual definition
    assert_match(/\bfruit\b/, get_definition("orange"))
    #Tolerance to capitalized words
    assert_match(/\bKingdom\b/, get_definition("england"))
    #Exclude information within html tags
    assert_no_match(/\bclass\b/, get_definition("light"))
    #Nonexistent words
    assert_match(/\bNOTFOUND\b/, get_definition("rndmstuff"))
    #Hard case with atypic html format:
    assert_match(/\bgenus\b/, get_definition("morus"))
    #Another atypic html format
    assert_match(/\blaw\b/, get_definition("los"))
  end
  
  
  def test_user_source
    extend PDSourceUser
    with_stdin do |user|
      user.puts "sweet fruit"
      assert_equal("sweet fruit", get_definition('orange'))
    end
  end
  
  
  private
  

  #neat solution
  #http://stackoverflow.com/questions/16948645/how-do-i-test-a-function-with-gets-chomp-in-it
  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end 
  
end

