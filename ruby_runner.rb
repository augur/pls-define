#!/usr/bin/env ruby
# encoding: utf-8

#This example script builds self-consistent dictionary starting with word 'Ruby' 
#It dumps data to 'ruby_dump.json'
#It retrieves definitions from web (dictionary.com) with 3 second period of rest between queries.

require_relative 'pd_runner'

DUMPFILE = 'ruby_dump.json'

puts "CTRL-C to stop this script safely."

begin
  init_data = File.exists?(DUMPFILE) ? DUMPFILE : 'Ruby'  
  runner = PDRunner.new(:web, init_data, true)
  runner.run(DUMPFILE, 3)
rescue Interrupt
rescue Exception
  puts "Retry in 15 seconds"
  sleep(15)
  retry
end

