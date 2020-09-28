#!/usr/bin/env ruby

require 'ruby2d'

require_relative 'lib/gfx'
require_relative 'lib/gfx/at_bat_box'

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
