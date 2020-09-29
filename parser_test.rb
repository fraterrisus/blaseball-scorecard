#!/usr/bin/env ruby

require 'json'
require_relative 'lib/event_parser'

events = JSON.parse(File.read('/home/bcordes/src/blaseball-scorecard/game-events.json'))
EventParser.new(events).parse.each { |ev| puts ev }
