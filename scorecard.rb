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
require_relative 'lib/at_bat_builder'
require_relative 'lib/event_parser'
require_relative 'lib/game'
require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'

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

builder = AtBatBuilder.new(@game, parsed_events)
builder.build
boxes = builder.game_at_bats

Window.set(
  background: 'white',
  title: 'Blaseball Scorecard',
)

scale = 1
maxy = 100 * scale * 9
y = 10
x = 10
boxes.each do |box|
  x2 = x
  box.each do |half, at_bats|
    if half == :top
      at_bats.each do |at_bat|
        options = {x: x, y: y, scale: scale}.merge(at_bat.to_h)
        new_box = GFX::AtBatBox.new(options)
        y = new_box.y2
        y = 10 if y > maxy
        x2 = new_box.x2
      end
    end
  end
  x = x2
end

Window.set(
  height: maxy + 20,
  width: x + 10
)

on :key_down do |event|
  if event.key == 'escape'
    exit
  end
end

Window.show
