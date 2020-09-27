#!/usr/bin/env ruby

require 'ruby2d'

BACKGROUND = Color.new([0.9, 0.9, 0.9, 1])
EMPTY_DOT = Color.new([0.8, 0.8, 0.8, 1])
SOLID_DOT = Color.new([0.2, 0.2, 0.2, 1])

Window.set(
  background: 'white',
  title: 'Blaseball Scorecard'
)


def at_bat_box(**opts)
  top = opts[:x]
  left = opts[:y]
  scale = opts[:scale]
  bases = opts[:bases] || [nil, nil, nil, nil]
  paths = opts[:paths] || [nil, nil, nil, nil]
  center_text = Array(opts[:center_text])
  corner_text = Array(opts[:corner_text])

  height = width = 100 * scale

  frame_width = 2 * scale
  basepath_width = 2 * scale
  solid_dot_radius = 5 * scale
  hollow_dot_radius = solid_dot_radius / 2
  circled_dot_radius = solid_dot_radius * 1.5
  diamond_radius = 20 * scale

  frame_radius = frame_width / 2

  # Outer frame
  Square.new(x: left - frame_radius, y: top - frame_radius,
    size: height + (2 * frame_radius), color: 'black', z: 5)

  # Inner frame
  Square.new(x: left + frame_radius, y: top + frame_radius,
    size: height - (2 * frame_radius), color: BACKGROUND, z: 6)

  # Balls
  4.times do |i|
    Circle.new(
      x: left + (2 * solid_dot_radius),
      y: top + (2 * solid_dot_radius) + ((2.5 * solid_dot_radius) * i),
      radius: solid_dot_radius,
      color: EMPTY_DOT,
      z: 10
    )
  end

  # Strikes
  3.times do |i|
    Circle.new(
      x: left + width - (2 * solid_dot_radius),
      y: top + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i),
      radius: solid_dot_radius,
      color: EMPTY_DOT,
      z: 10
    )
  end

  # RBIs
  4.times do |i|
    Circle.new(
      x: top + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i),
      y: left + height - (2 * solid_dot_radius),
      radius: solid_dot_radius,
      color: EMPTY_DOT,
      z: 10
    )
  end

  t = top + (width / 2)
  dot_x = [t + diamond_radius, t, t - diamond_radius, t]
  t = left + (height / 2)
  dot_y = [t, t - diamond_radius, t, t + diamond_radius]
  dot_x << dot_x[0]
  dot_y << dot_y[0]

  4.times do |i|
    case bases[i]
    when :solid
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: SOLID_DOT, z: 20)
    when :solid_crossed
      draw_crossed_dot(x: dot_x[i], y: dot_y[i], length: 4 * solid_dot_radius / 3,
        width: solid_dot_radius / 3, color: 'black', z: 22)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: SOLID_DOT, z: 20)
    when :hollow
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: SOLID_DOT, z: 20)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
    when :hollow_crossed
      draw_crossed_dot(x: dot_x[i], y: dot_y[i], length: 4 * solid_dot_radius / 3,
        width: solid_dot_radius / 3, color: 'black', z: 22)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: SOLID_DOT, z: 20)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
    when :crossed
      draw_crossed_dot(x: dot_x[i], y: dot_y[i], length: 2 * solid_dot_radius / 3,
        width: solid_dot_radius / 2, color: 'black', z: 22)
    when :crossed_circled
      draw_crossed_dot(x:dot_x[i], y:dot_y[i], length: 2 * solid_dot_radius / 3,
        width: solid_dot_radius / 2, color: 'black', z: 22)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: circled_dot_radius, color: SOLID_DOT, z:19)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: BACKGROUND, z: 20)
    else
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: EMPTY_DOT, z: 10)
    end

    hash_length = 2 * basepath_width
    mid_x = (dot_x[i] + dot_x[(i+3)%4]) / 2
    mid_y = (dot_y[i] + dot_y[(i+3)%4]) / 2
    case paths[i]
    when :solid
      line_color = Color.new('black')
    when :hashed
      line_color = Color.new('black')
      if i % 2 == 0
        Line.new(
          x1: mid_x - hash_length, x2: mid_x + hash_length,
          y1: mid_y - hash_length, y2: mid_y + hash_length,
          width: basepath_width, color: 'black', z: 18
        )
      else
        Line.new(
          x1: mid_x - hash_length, x2: mid_x + hash_length,
          y1: mid_y + hash_length, y2: mid_y - hash_length,
          width: basepath_width, color: 'black', z: 18
        )
      end
    when :double_hashed
      line_color = Color.new('black')
      if i % 2 == 0
        Line.new(
          x1: mid_x - hash_length + basepath_width, x2: mid_x + hash_length + basepath_width,
          y1: mid_y - hash_length - basepath_width, y2: mid_y + hash_length - basepath_width,
          width: basepath_width, color: 'black', z: 18
        )
        Line.new(
          x1: mid_x - hash_length - basepath_width, x2: mid_x + hash_length - basepath_width,
          y1: mid_y - hash_length + basepath_width, y2: mid_y + hash_length + basepath_width,
          width: basepath_width, color: 'black', z: 18
        )
      else
        Line.new(
          x1: mid_x - hash_length - basepath_width, x2: mid_x + hash_length - basepath_width,
          y1: mid_y + hash_length - basepath_width, y2: mid_y - hash_length - basepath_width,
          width: basepath_width, color: 'black', z: 18
        )
        Line.new(
          x1: mid_x - hash_length + basepath_width, x2: mid_x + hash_length + basepath_width,
          y1: mid_y + hash_length + basepath_width, y2: mid_y - hash_length + basepath_width,
          width: basepath_width, color: 'black', z: 18
        )
      end
    else
      line_color = EMPTY_DOT
    end
    Line.new(x1: dot_x[(i+3)%4], x2: dot_x[i], y1: dot_y[(i+3)%4], y2: dot_y[i],
      width: basepath_width, color: line_color, z: 18)
  end

  process_text(x: left + (width / 2), y: top + (height / 2), scale: scale, data: center_text)

  process_text(x: left + width - (3 * solid_dot_radius), y: top + height - (3 * solid_dot_radius),
    scale: scale, data: corner_text)
end

def center(text)
  text.x = text.x - (text.width / 2)
  text.y = text.y - (text.height / 2)
end

def draw_crossed_dot(x:, y:, length:, width:, color:, z:)
  cross_x = [x - length, x + length]
  cross_y = [y - length, y + length]
  one = Line.new(x1: cross_x[0], y1: cross_y[0], x2: cross_x[1], y2: cross_y[1],
    width: width, color: color, z: z)
  two = Line.new(x1: cross_x[0], y1: cross_y[1], x2: cross_x[1], y2: cross_y[0],
    width: width, color: color, z: z)
  [one, two]
end

def process_text(x:, y:, scale:, data:)
  text_rotate = 0
  text_string = nil
  Array(data).each do |elt|
    case elt
    when :circled
      Circle.new(x: x, y: y, radius: 12 * scale, color: 'black', z: 28)
      Circle.new(x: x, y: y, radius: 10 * scale, color: BACKGROUND, z: 29)
    when :squared
      Square.new(x: x - (10 * scale), y: y - (10 * scale),
        size: 20 * scale, color: 'black', z: 28)
      Square.new(x: x - (8 * scale), y: y - (8 * scale),
        size: 16 * scale, color: BACKGROUND, z: 29)
    when :reversed
      text_rotate = 180
    when String, Numeric
      text_string = elt.to_s
    end
  end
  if text_string
    center(Text.new(text_string, x: x, y: y,
      size: 12 * scale, rotate: text_rotate, color: 'black', z: 30))
  end
end

at_bat_box(x:10, y:10, scale:4,
  bases: [:hollow_crossed, :solid_crossed, :crossed_circled],
  paths: [:solid, :hashed],
  center_text: ['K', :reversed, :squared],
  corner_text: ['F', :circled])

Window.show
