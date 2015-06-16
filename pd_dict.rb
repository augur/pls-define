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
    @data = {}
    if valid?(init_data) #proper word, init dictionary with it
      @data[process_word(init_data)] = nil
    else #may be filename of storage
      @storage = init_data
      load_data()
    end
  end
  
  #TODO give first undefined word from @data
  def request_definition()
  end
  
  #Adds definition for existing word. Also adds new words to define
  def add_definition(word, definition)
    if (@data.has_key?(word) and @data[word] == nil and definition.is_a? String)
      @data[word] = definition
      definition.split.each do | w |
          new_word = process_word(w)
          if valid?(new_word) and !@data.has_key?(new_word)
            @data[new_word] = nil
          end
      end
    else
      raise ArgumentError
    end
  end
  
  private
  
  def process_word(word)
    #leave only latin letters(used to strip words from definition) and downcase
    return word.match(/[a-zA-Z]+/).to_s.downcase
  end
  
  def valid?(s)
    #is it just plain latin?
    s.match(/[^a-zA-Z]/).to_s == "" and s.length > 0
  end
  
  def load_data() 
    #TOTHINK: is it correct to raise ArgumentErr upon instance vars?
    raise ArgumentError unless File.exist?(@storage)
  end
  
  def save_data()
    #dump @data to @storage
  end
  
end
