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

require_relative 'lib/event_parser'
require_relative 'lib/game'
require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'

# @game = Game.new(game_id: '5631a0fa-bc2a-4fba-9787-51a6b4f7cabf')

Window.set(
  background: 'white',
  title: 'Blaseball Scorecard'
)


GFX::AtBatBox.new(x: 10, y: 10, scale: 4,
  bases: [:hollow_crossed, :solid_crossed, :crossed_circled],
  paths: [:solid, :hashed],
  strikes: [:solid, :hollow, :crossed, :crossed, :hollow],
  balls: [:solid, :solid, :solid],
  rbis: 2,
  center_text: ['K', :reversed, :squared],
  corner_text: ['F', :circled])

on :key_down do |event|
  if event.key == 'escape'
    exit
  end
end

Window.show
