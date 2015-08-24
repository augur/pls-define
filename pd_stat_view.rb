#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'uri'

require 'pd_dict'
require 'pd_source' #Mostly for NO_DEF const

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
  
  def ui_loop
    #loop
      #read keys
      #case print data
      #exit on interrupt
  end
  
  
  def ui_traverse(word)
    decision = ""
    until decision == '0'
      print word + ": "
      defn, words = traverse_step(word)
      break if words.nil?
      puts defn
      words.each_with_index do |w, i|
        puts "#{i+1}. #{w[0]} (#{w[1]})"
      end
      puts "...\n0. Exit"
      print "Choose next word by its index: "
      decision = gets.chomp!
      word = words[decision.to_i-1][0]
    end
  end
  
  
  def self_consistent?
    return dict.request_definition.nil?
  end
  
  
  def get_count
    return dict.data.size
  end
  
  
  def get_top_refs(n = 100, rev = true)
    sorted = dict.ref_stat.sort_by {|word, count| count}
    sorted.reverse! if rev
    return sorted[0...n] 
  end
  
  
  def get_no_def
    return (dict.data.select {|k, v| v == NO_DEF}).keys
  end
  
  
  def get_word (i = nil)
    i = rand(get_count) if i.nil?
    return dict.data.keys[i]
  end
  
  
  private
  
  
  # Return definitions, words and refs
  def traverse_step(word)
    defn = dict.get_definition(word)
    words = defn.split.map { |w| [w, dict.get_ref_count(w)] } unless defn.nil?
    return defn, words
  end
  
  
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

