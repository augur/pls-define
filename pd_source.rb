#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'uri'

module PDSourceUser
  
  def get_definition(word)
    print "Please, define '#{word}': "
    return gets.chomp!
  end
  
end


module PDSourceWeb
  
  def get_definition(word)
    #TODO: deal with side effect
    word.downcase!
    begin
      url = build_url(word)
      body = get_body(url)
      return parse_body(body, word)
    rescue Net::HTTPServerException
      return "NOTFOUND" #Special word if nothing found
    end
  end
  
  
  private

  
  def build_url(word)
    return 'http://dictionary.reference.com/browse/' + word
  end

  
  def get_body(url)
    return fetch(url).body.force_encoding("UTF-8")  
  end
  
  
  #Aye, regexing html isn't very good, unless you need just a few things
  #Dont want to include nokigiri as a requirement
  def parse_body(body, word)
    body = body.partition('<h1 class="head-entry"><span class="me" data-syllable').last
    origin_word = body.match(/">(.*?)<\/span>/)[1].downcase
    if (word == origin_word) 
      body = body.partition('def-content">')[2]
      body = body.match(/(.*?)<\/div>/)[1]
      #get rid of html tags, then return      
      return body.gsub(/<\/?[^>]+>/, '')
    else #asked word transformed to origin_word, thus just refer to it.
      return origin_word
    end
  end

  
  #"Following redirection" script from stackoverflow.com
  #http://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
  def fetch(uri_str, limit = 10)
    #TODO choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(uri_str)
    req = Net::HTTP::Get.new(url.path)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end
  
end
