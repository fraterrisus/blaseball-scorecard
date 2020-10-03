#!/usr/bin/env ruby

# Notorious games:
# S8 D48 Mills v Lovers: Don Mitchell reverberates (multiple times)
#   https://reblase.sibr.dev/game/5631a0fa-bc2a-4fba-9787-51a6b4f7cabf
# S5 D5  Fridays v Magic: full-lineup reverb
#   https://reblase.sibr.dev/game/8ef67ba1-aab3-4129-92a3-d258ae9a4358

require 'ruby2d'

require_relative 'lib/event_parser'
require_relative 'lib/game'
require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'
require_relative 'lib/plate_appearance'
require_relative 'lib/scorecard_builder'

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
scorecard = ScorecardBuilder.new(@game, parsed_events)
boxes = scorecard.game_at_bats

Window.set(
  background: 'white',
  title: 'Blaseball Scorecard',
)

def draw_batter_label(scale, batter, spot)
  text = Text.new(batter, x: 20, y: 100 * scale * (spot + 0.5) + 25,
    size: 18 * scale, color: 'black', z: 5)
end

def draw_inning_label(scale, inning)
  @columns << inning
  text_x = (100 * scale * (inning - 0.5)) + 310
  text_y = (100 * scale / 4) + 10
  text = Text.new(inning.to_s, x: text_x, y: text_y, size: 24 * scale, color: 'black', z: 5)
  text.x = text.x - (text.width / 2)
  text.y = text.y - (text.height / 2)
end

def draw_inning_score(scale, inning, score)
  idx = @columns.rindex(inning)
  text_x = (100 * scale * (idx + 0.5)) + 310
  text_y = (100 * scale * (9.75))
  text = Text.new(score.to_s, x: text_x, y: text_y, size: 24 * scale, color: 'black', z: 5)
  text.x = text.x - (text.width / 2)
  text.y = text.y - (text.height / 2)
end

scale = 1.5
maxy = (100 * scale * (9 + 1))
start_y = 100 * scale / 2
start_x = 300 + 10
draw_for_team = 'home'
draw_for_half = :bottom
@columns = []

@game.lineups[draw_for_team].each_with_index do |batter, spot|
  name = batter['player_name']
  draw_batter_label(scale, name, spot)
end

y = start_y
x = start_x
y_index = 0
inning = 0

boxes.each do |box|
  x2 = x
  inning += 1
  draw_inning_label(scale, inning)
  batted_around = y_index
  box.each do |half, at_bats|
    if half == draw_for_half
      at_bats.each do |at_bat|
        options = {x: x, y: y, scale: scale}.merge(at_bat.to_h)
        new_box = GFX::AtBatBox.new(options)

        y = new_box.y2
        y_index += 1
        if y_index == 9
          y = start_y
          y_index = 0
        end
        x2 = new_box.x2
        if y_index == batted_around
          x = x2
          draw_inning_label(scale, inning)
        end
      end
    end
  end
  # Draw end-of-inning marker
  Line.new(x1: x2 - (100 * scale), x2: x2, y1: y, y2: y,
    width: 8 * scale, color: Color.new([0.5, 0, 0, 1.0]), z: 75)
  x = x2
end

(@columns.count+1).times do |col|
  x = start_x + (100 * col * scale)
  Line.new(x1: x, x2: x, y1: 10, y2: maxy - 10, color: GFX::BLUE_LINE, z: 5)
end
y = start_y
10.times do
  Line.new(x1: 10, x2: x + 20, y1: y, y2: y, color: GFX::BLUE_LINE, z: 5)
  y += 100 * scale
end

scorecard.game_score.each_with_index do |inning, idx|
  draw_inning_score(scale, idx+1, inning[draw_for_half])
end

Window.set(
  height: maxy,
  width: (@columns.count * 100 * scale) + 350
)

on :key_down do |event|
  if event.key == 'escape'
    exit
  end
end

Window.show
