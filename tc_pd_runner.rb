#!/usr/bin/env ruby
# encoding: utf-8

require_relative "pd_runner"
require "test/unit"

class TestPDRunner < Test::Unit::TestCase
  
  def test_init
    assert_nothing_raised(Exception) {
      PDRunner.new(:web, 'orange')
    }

    assert_nothing_raised(Exception) {
      PDRunner.new(:user, 'orange')
    }
    
    assert_raise(ArgumentError) {
      PDRunner.new(:unknown, 'orange')
    }
  end
  
  #Barely can test PDRunner#run, cause of its looping 
  def test_run
    with_stdin do |user|
      p = PDRunner.new(:user, 'test')
      user.puts "some"
      user.puts "test"
      p.run('test.json', 0)
      assert_equal({"test" => "some", "some" => "test"}, p.dict.data)
      
      assert(File.exists?('test.json'))
      
      p2 = PDRunner.new(:user, 'test.json')
      assert(p2.dict.data == p.dict.data)
      
      File.delete('test.json')
    end
  end
  
  
  private
  
  
  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end   
  
end  

