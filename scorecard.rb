#!/usr/bin/env ruby

require 'ruby2d'

BACKGROUND = Color.new([0.9, 0.9, 0.9, 1])
EMPTY_DOT = Color.new([0.8, 0.8, 0.8, 1])

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

  height = width = 100 * scale

  frame_width = 2 * scale
  basepath_width = 2 * scale
  solid_dot_radius = 5 * scale
  hollow_dot_radius = solid_dot_radius / 2
  circled_dot_radius = solid_dot_radius * 1.5
  diamond_radius = 20 * scale

  frame_radius = frame_width / 2

  # Outer frame
  Square.new(
    x: top - frame_radius, y: left - frame_radius,
    size: height + (2 * frame_radius),
    color: 'black',
    z: 5
  )

  # Inner frame
  Square.new(
    x: top + frame_radius, y: left + frame_radius,
    size: height - (2 * frame_radius),
    color: BACKGROUND,
    z: 6
  )

  # Balls
  4.times do |i|
    Circle.new(
      x: top + (2 * solid_dot_radius),
      y: left + (2 * solid_dot_radius) + ((2.5 * solid_dot_radius) * i),
      radius: solid_dot_radius,
      color: EMPTY_DOT,
      z: 10
    )
  end

  # Strikes
  3.times do |i|
    Circle.new(
      x: top + width - (2 * solid_dot_radius),
      y: left + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i),
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
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: 'black', z: 20)
    when :solid_crossed
      cross_x = [dot_x[i] - (4 * solid_dot_radius / 3), dot_x[i] + (4 * solid_dot_radius / 3)]
      cross_y = [dot_y[i] - (4 * solid_dot_radius / 3), dot_y[i] + (4 * solid_dot_radius / 3)]
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: 'black', z: 20)
      Line.new(x1: cross_x[0], y1: cross_y[0], x2: cross_x[1], y2: cross_y[1],
        width: solid_dot_radius / 3, color: 'black', z: 22)
      Line.new(x1: cross_x[0], y1: cross_y[1], x2: cross_x[1], y2: cross_y[0],
        width: solid_dot_radius / 3, color: 'black', z: 22)
    when :hollow
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: 'black', z: 20)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
    when :hollow_crossed
      cross_x = [dot_x[i] - (4 * solid_dot_radius / 3), dot_x[i] + (4 * solid_dot_radius / 3)]
      cross_y = [dot_y[i] - (4 * solid_dot_radius / 3), dot_y[i] + (4 * solid_dot_radius / 3)]
      Circle.new(x: dot_x[i], y: dot_y[i], radius: solid_dot_radius, color: 'black', z: 20)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
      Line.new(x1: cross_x[0], y1: cross_y[0], x2: cross_x[1], y2: cross_y[1],
        width: solid_dot_radius / 3, color: 'black', z: 22)
      Line.new(x1: cross_x[0], y1: cross_y[1], x2: cross_x[1], y2: cross_y[0],
        width: solid_dot_radius / 3, color: 'black', z: 22)
    when :crossed
      cross_x = [dot_x[i] - (2 * solid_dot_radius / 3), dot_x[i] + (2 * solid_dot_radius / 3)]
      cross_y = [dot_y[i] - (2 * solid_dot_radius / 3), dot_y[i] + (2 * solid_dot_radius / 3)]
      Line.new(x1: cross_x[0], y1: cross_y[0], x2: cross_x[1], y2: cross_y[1],
        width: solid_dot_radius / 2, color: 'black', z: 22)
      Line.new(x1: cross_x[0], y1: cross_y[1], x2: cross_x[1], y2: cross_y[0],
        width: solid_dot_radius / 2, color: 'black', z: 22)
    when :crossed_circled
      cross_x = [dot_x[i] - (2 * solid_dot_radius / 3), dot_x[i] + (2 * solid_dot_radius / 3)]
      cross_y = [dot_y[i] - (2 * solid_dot_radius / 3), dot_y[i] + (2 * solid_dot_radius / 3)]
      Line.new(x1: cross_x[0], y1: cross_y[0], x2: cross_x[1], y2: cross_y[1],
        width: solid_dot_radius / 2, color: 'black', z: 22)
      Line.new(x1: cross_x[0], y1: cross_y[1], x2: cross_x[1], y2: cross_y[0],
        width: solid_dot_radius / 2, color: 'black', z: 22)
      Circle.new(x: dot_x[i], y: dot_y[i], radius: circled_dot_radius, color: 'black', z:19)
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

  # Center text
  Text.new('strike', x: left + (width / 2), y: top + (height / 2),
    size: 18, color: 'black', rotate: 180, z: 30)

end

at_bat_box(x:10, y:10, scale:4,
  bases: [:hollow, :solid, :crossed],
  paths: [:solid, :hashed])

Window.show
