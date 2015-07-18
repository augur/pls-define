#!/usr/bin/env ruby
# encoding: utf-8


require_relative "pd_dict"
require_relative "pd_source"
require 'logger'


#Top-level class, who makes job done: operates Dictionary and fills it using source.
class PDRunner
  
  #Here lies PDDict
  attr_reader :dict

  
  def initialize(source, init_data, verbose = false)
    @verbose = verbose
    @logger = Logger.new(STDOUT) if @verbose
    
    set_source(source)
    
    @dict = PDDict.new(init_data, @verbose)
  end
  
  
  def set_source(source)
    case source
      when :user
        extend PDSourceUser
      when :web
        extend PDSourceWeb
    else
      raise ArgumentError
    end
    log "Source set to #{source}"
  end
  

  def run(savename = nil, cooldown = 1.0)
    begin
      word = @dict.request_definition()
      if (word) 
        @dict.add_definition(word, get_definition(word))
      else
        log "Dictionary became self-consistent!"
        break
      end
      sleep(cooldown)
    #Yep, catch ANY, especially CTRL-C. 
    rescue Exception => e
      log "Caught " + e.inspect + ", stopping"
      save(savename)
      raise
    end while true
    save(savename) #This only occurs if loop ended by break
  end
  
  
  
  private
  
  
  def save(savename)
    log "Saving to " + savename
    @dict.save(savename)
  end
  
  
  #Same as in PDDict. Seems need to be reworked as mixin.
  def log(s)
    @logger.info(s) if @verbose
  end
  
end

