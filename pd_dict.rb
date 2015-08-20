#!/usr/bin/env ruby
# encoding: utf-8

require 'logger'
require 'json'

#"Please Define" Dictionary - class that works with dictionary data 
class PDDict
  
  #actual hash-container of dictionary
  attr_reader :data
  #reference counting hash
  attr_reader :ref_stat
  #file, which keeps dictionary data between runs (JSON-formatted)
  attr_reader :storage

  
  #init_data - either first, undefined word to start, or filename of storage  
  def initialize(init_data, verbose = false)
    raise ArgumentError unless (init_data.is_a? String)
    @data = {}
    #auxiliary array for making undefined words search among @data more efficient
    @undef_words = []
    @ref_stat = {}
    @verbose = verbose
    @logger = Logger.new(STDOUT) if @verbose
    if valid?(init_data) #proper word, init dictionary with it
      log "inited with word: '#{init_data}'"
      add_word(process_word(init_data))
    else #may be filename of storage
      log "init from file: #{init_data}"
      @storage = init_data
      load_data()
    end
  end

  
  #if it returns nil, then dictionary is completed
  def request_definition()
    log @undef_words.size.to_s + ' words to define.'
    result = @undef_words[0]
    log "define: '#{result}'"
    return result    
  end
  
  
  #Adds definition for existing word. Also adds new words to define
  def add_definition(word, definition)
    if (@data.has_key?(word) and @data[word].nil? and definition.is_a? String)
      log "'#{word}' defined as: '#{definition}'"
      @data[word] = definition
      @undef_words.delete(word)
      new_words = definition.split.map { |w| process_word(w) }.uniq
      new_words.each do |new_word|
          if valid?(new_word) 
            add_word(new_word) unless @data.has_key?(new_word)
            #word repeating in definition doesn't count as reference
            unless (word == new_word) 
              if (@ref_stat[new_word].nil?) 
                @ref_stat[new_word] = 1
              else
                @ref_stat[new_word] += 1
              end
            end
          end
      end
    else
      raise ArgumentError
    end
  end
  
  
  #Checks dictionary for word, safely
  def get_definition(unsafe_word)
    return @data[process_word(unsafe_word)]
  end
  
  
  def get_ref_count(unsafe_word)
    res = @ref_stat[process_word(unsafe_word)]
    return res || 0
  end
  
  
  def save(storage = nil)
    unless storage.nil?
      raise ArgumentError unless storage.is_a? String
      @storage = storage 
    end
    log "asked to save data in '#{@storage}'"
    save_data()
  end

  
  private
  
  
  def add_word(word)
    log "'#{word}' added"
    @data[word] = nil
    @undef_words << word
  end

  
  def process_word(word)
    #leave only latin letters(used to strip words from definition) and downcase
    return word.match(/[a-zA-Z]+/).to_s.downcase
  end

  
  def valid?(s)
    #is it just plain latin?
    s.match(/[^a-zA-Z]/).to_s == "" and s.length > 0
  end

  
  def log(s)
    @logger.info(s) if @verbose
  end
  
  
  def load_data() 
    raise ArgumentError unless File.exist?(@storage)
    @data, @undef_words, @ref_stat = JSON.parse(File.read(@storage))
    log 'load success'
  end


  def save_data()
    raise ArgumentError if @storage.nil?
    prev_save = @storage
    now_save = @storage + '.new'
    old_save = @storage + '.old'
    
    if File.exist?(now_save)
      log "Previous save() wasn't successful: check for .new file"
      i = 0
      begin
        i += 1
        temp_dump = now_save + i.to_s
      end while File.exist?(temp_dump)
      File.open(temp_dump, 'w') { |f| f.puts [@data, @undef_words, @ref_stat].to_json }
      log "data dumped to " + temp_dump
      return
    end
    
    File.open(now_save, 'w') { |f| f.puts [@data, @undef_words, @ref_stat].to_json }
    
    prev_size = File.exist?(prev_save) ? File.size(prev_save) : 0
    now_size = File.size(now_save)
    
    if now_size >= prev_size
        # all is fine
        File.delete(old_save) if File.exist?(old_save)
        File.rename(prev_save, old_save) if File.exist?(prev_save)
        File.rename(now_save, @storage)
        log 'save success'
    else
        # this shouldn't happen
        raise "Previous save file is larger! Something must be wrong."
    end
  end

end

