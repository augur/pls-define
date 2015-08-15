#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'uri'

require 'pd_dict'

class PDStatView
  
  #PDDict here
  attr_reader :dict
  
  def initialize(stat_path)
    get_local(stat_path)
    if @dict.nil?
      get_www(stat_path)
      if @dict.nil?
        raise "Unable to get Stat-data from specified path"
      end
    end
  end
  
  
  
  private
  
  def get_local(path)
    begin
      dict = PDDict.new(path)
      @dict = dict
    #it is a bit rough to catch any type...
    rescue Exception => e
      # open failed
    end
  end
  
  
  TMP = 'www_stat.json'
  
  def get_www(url)
    begin
      uri = URI url
      body = Net::HTTP.get_response(uri).body.force_encoding("UTF-8")
      File.open(TMP, 'w') { |f| f.puts body }
      get_local(TMP)
    rescue Exception => e
      # open failed
    ensure
      File.delete(TMP) if File.exist?(TMP)
    end
  end

end

