#!/usr/bin/env ruby
#encoding: utf-8

#"Please Define" Dictionary - class that works with dictionary data 
class PDDict
  
  #actual hash-container of dictionary
  attr_reader :data
  #file, which keeps dictionary data between runs (JSON-formatted)
  attr_reader :storage

  #init_data - either first, undefined word to start, or filename of storage  
  def initialize(init_data)
    raise ArgumentError unless (init_data.is_a? String)
    if valid?(init_data)
      #proper word, init dictionary with it
      @data = {process_word(init_data) => nil}
    else
      #may be filename of storage
      @storage = init_data
      load_data()
    end
  end
  
  private
  
  def process_word(word)
    #more processing may be added
    return word.downcase
  end
  
  def valid?(s)
    #is it just plain latin?
    s.match(/[^a-zA-Z]/).to_s == ""
  end
  
  def load_data() 
    #TOTHINK: is it correct to raise ArgumentErr upon instance vars?
    raise ArgumentError unless File.exist?(@storage)
  end
  
  def save_data()
    #dump @data to @storage
  end
  
end
