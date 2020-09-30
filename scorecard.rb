#!/usr/bin/env ruby

# Notorious games:
# S8 D48 Mills v Lovers: Don Mitchell reverberates (multiple times)
#   https://reblase.sibr.dev/game/5631a0fa-bc2a-4fba-9787-51a6b4f7cabf
# S5 D5  Fridays v Magic: full-lineup reverb
#   https://reblase.sibr.dev/game/8ef67ba1-aab3-4129-92a3-d258ae9a4358
#
# Notation check:
#   maybe walks should also have an open circle at 1st since they aren't at-bats

require 'ruby2d'

require_relative 'lib/at_bat'
require_relative 'lib/event_parser'
require_relative 'lib/game'
require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'

class GameFile < Game
  def initialize(events:, lineups:)
    @events = events
    @lineups = lineups
  end
end

arg = ARGV[0]
if File.exist?(arg)
  raw_events = JSON.parse(File.read(arg))
  raw_lineups = JSON.parse(File.read(arg.sub('updates', 'lineups')))
  @game = GameFile.new(events: raw_events, lineups: raw_lineups)
else
  @game = Game.new(game_id: arg)
  File.write("chr-game-updates-#{arg}.json", @game.events.to_json)
  File.write("chr-game-lineups-#{arg}.json", @game.lineups.to_json)
end

parsed_events = EventParser.new(@game.events).parse

def diff_runners_on_hit(prev, new, prev_at_bats)
  new_at_bats = [nil, nil, nil, nil]
  prev.each do |id, prev_base|
    runner = prev_at_bats[prev_base+1] # incoming base IDs are -1 based; array index is 0-based
    raise "Runner mismatch at base #{prev_base+1}, expected #{id}, found #{runner.id}" unless id == runner.id
    new_base = new[id]+1 || 3
    runner.advance_to(new_base)
    new_at_bats[new_base] = runner unless new_base == 3
  end
  new_at_bats
end

game_at_bats = []
current_inning = 0
current_half_inning = nil
current_at_bats = []
current_runners = {}
inning_at_bats = []
parsed_events.each do |ev|
  puts ev

  case ev[:event]
  when :start_of_inning
    break if inning_at_bats.any?
    inning_at_bats = []
    current_inning = ev[:inning]
    current_half_inning = ev[:half]
    current_at_bats = [ nil, nil, nil, nil ]
  when :start_of_at_bat
    raise 'Home plate is occupied!' unless current_at_bats[0].nil?
    new_at_bat = AtBat.new(id: ev[:id])
    current_at_bats[0] = new_at_bat
    inning_at_bats << new_at_bat
  when :end_of_at_bat
    case ev[:type]
    when :flyout
      fielder_index = @game.their_lineup(current_half_inning == :top).index do |p|
        p['player_name'] == ev[:fielder_name]
      end
      current_at_bats[0].fly_out_to(fielder_index)
    when :groundout
      fielder_index = @game.their_lineup(current_half_inning == :top).index do |p|
        p['player_name'] == ev[:fielder_name]
      end
      current_at_bats[0].ground_out_to(fielder_index)
    when :single, :double, :triple, :home_run
      hitter_id = current_at_bats[0].id
      prev_runners = current_runners.merge(hitter_id => -1)
      new_runners = ev[:runner_ids]
      current_at_bats = diff_runners_on_hit(prev_runners, new_runners, current_at_bats)
      current_runners = new_runners
    when :stolen_base
    else
      raise 'Unrecognized event type!'
    end
    current_at_bats[0] = nil
  when :ball
    current_at_bats[0].ball
  when :strike
    current_at_bats[0].strike(ev[:type])
  else
    raise 'Unrecognized event!'
  end
end

Window.set(
  background: 'white',
  title: 'Blaseball Scorecard',
  height: 800,
  width: 400
)

x = 10
y = 10
inning_at_bats.each do |at_bat|
  options = {x: x, y: y, scale: 2}.merge(at_bat.to_h)
  new_box = GFX::AtBatBox.new(options)
  y = new_box.y2
end

Window.set(
  height: y + 10
)

on :key_down do |event|
  if event.key == 'escape'
    exit
  end
end

Window.show
