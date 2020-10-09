#!/usr/bin/env ruby

require 'optparse'
require 'ruby2d'

require_relative 'lib/event_parser'
require_relative 'lib/game'
require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'
require_relative 'lib/plate_appearance'
require_relative 'lib/scorecard_builder'

@options = {}
OptionParser.new do |opts|
  opts.on('-hHALF', '--half HALF',
    %w(top bottom), { 'bot' => 'bottom' },
    'Half inning to display (top or bot[tom])')
end.parse!(into: @options)

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
  Text.new(batter, x: 20, y: 100 * scale * (spot + 0.5) + 25,
    size: 18 * scale, color: 'black', z: 5)
end

def draw_inning_label(scale, index, inning)
  @columns << inning
  text_x = (100 * scale * (index + 0.5)) + 310
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

if @options[:half] == 'bottom'
  draw_for_team = 'home'
  draw_for_half = :bottom
else
  draw_for_team = 'away'
  draw_for_half = :top
end

draw_lineup = @game.lineups[draw_for_team]
@columns = []

draw_lineup.each_with_index do |batter, spot|
  name = batter['player_name']
  draw_batter_label(scale, name, spot)
end

inning = 0
inning_index = -1

boxes.each do |box|
  inning += 1
  inning_index += 1
  draw_inning_label(scale, inning_index, inning)
  # puts "#{draw_for_half} #{inning}"
  boxes_filled = [false] * 9
  previous_batter = nil

  appearances = box[draw_for_half] || []
  appearances.each do |at_bat|
    batters_lineup_idx = draw_lineup.index { |bat| bat['player_id'] == at_bat.id }
    box_to_fill = batters_lineup_idx
    repeating_batter = (previous_batter == at_bat.id)
    # print "Batter: #{at_bat.id} Lineup position: #{batters_lineup_idx + 1}"
    if repeating_batter
      # puts '*'
      started_at = box_to_fill
      while boxes_filled[box_to_fill]
        box_to_fill = (box_to_fill + 1) % 9
        if box_to_fill == started_at
          inning_index += 1
          draw_inning_label(scale, inning_index, inning)
          boxes_filled = [false] * 9
        end
      end
    else
      # puts
      if boxes_filled[box_to_fill]
        inning_index += 1
        draw_inning_label(scale, inning_index, inning)
        boxes_filled = [false] * 9
      end
    end

    #puts "Filling box (#{inning_index+1},#{box_to_fill+1})"
    boxes_filled[box_to_fill] = true

    options = at_bat.to_h.merge(
      x: start_x + (inning_index * 100 * scale),
      y: start_y + (box_to_fill * 100 * scale),
      # repeating: repeating_batter,
      scale: scale)
    new_box = GFX::AtBatBox.new(options)

    # Start-of-inning marker
    if appearances.first == at_bat
      Line.new(x1: new_box.x1, x2: new_box.x1 + (25 * scale), y1: new_box.y1, y2: new_box.y1,
        width: 6 * scale, color: Color.new([0.5, 0, 0, 1.0]), z: 75)
      Line.new(x1: new_box.x1, x2: new_box.x1, y1: new_box.y1, y2: new_box.y1 + (25 * scale),
        width: 6 * scale, color: Color.new([0.5, 0, 0, 1.0]), z: 75)
    end

    # End-of-inning marker
    if appearances.last == at_bat
      Line.new(x1: new_box.x2 - (25 * scale), x2: new_box.x2, y1: new_box.y2, y2: new_box.y2,
        width: 6 * scale, color: Color.new([0.5, 0, 0, 1.0]), z: 75)
      Line.new(x1: new_box.x2, x2: new_box.x2, y1: new_box.y2 - (25 * scale), y2: new_box.y2,
        width: 6 * scale, color: Color.new([0.5, 0, 0, 1.0]), z: 75)
    end

    # Reverbing batter marker
    if repeating_batter
      line_x = (new_box.x1 + new_box.x2) / 2
      Triangle.new(
        x1: line_x - 10 * scale, y1: new_box.y1 - 10 * scale,
        x2: line_x + 10 * scale, y2: new_box.y1 - 10 * scale,
        x3: line_x, y3: new_box.y1 + 10 * scale,
        color: 'blue', z: 80)
    end

    previous_batter = at_bat.id
  end
end

x = 0
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
