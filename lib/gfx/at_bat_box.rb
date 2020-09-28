module GFX
  class AtBatBox
    def initialize(x:, y:, scale:, **opts)
      @top = x
      @left = y
      @scale = scale

      balls = opts[:balls] || [nil, nil, nil, nil]
      strikes = opts[:strikes] || [nil, nil, nil]
      rbis = opts[:rbis] || 0
      bases = opts[:bases] || [nil, nil, nil, nil]
      paths = opts[:paths] || [nil, nil, nil, nil]
      center_text = Array(opts[:center_text])
      corner_text = Array(opts[:corner_text])

      @height = @width = 100 * @scale

      @basepath_width = 2 * @scale
      @solid_dot_radius = 5 * @scale
      @hollow_dot_radius = @solid_dot_radius / 2
      @circled_dot_radius = @solid_dot_radius * 1.5
      @diamond_radius = 20 * @scale

      draw_outer_frame
      draw_data_dots(balls: balls, strikes: strikes, rbis: rbis)
      draw_diamond(bases: bases, paths: paths)
      draw_center_text(center_text)
      draw_corner_text(corner_text)
    end

    def x1
      @left
    end

    def x2
      @left + @width
    end

    def y1
      @top
    end

    def y2
      @top + @height
    end

    private

    attr_reader :basepath_width, :circled_dot_radius, :diamond_radius, :hollow_dot_radius,
      :scale, :solid_dot_radius

    def center(text)
      text.x = text.x - (text.width / 2)
      text.y = text.y - (text.height / 2)
    end

    def draw_base(x:, y:, data:)
      case data
      when :solid
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: SOLID_DOT, z: 20)
      when :solid_crossed
        draw_crossed_dot(x: x, y: y, length: 4 * solid_dot_radius / 3,
          width: solid_dot_radius / 3, color: 'black', z: 22)
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: SOLID_DOT, z: 20)
      when :hollow
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: SOLID_DOT, z: 20)
        Circle.new(x: x, y: y, radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
      when :hollow_crossed
        draw_crossed_dot(x: x, y: y, length: 4 * solid_dot_radius / 3,
          width: solid_dot_radius / 3, color: 'black', z: 22)
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: SOLID_DOT, z: 20)
        Circle.new(x: x, y: y, radius: hollow_dot_radius, color: EMPTY_DOT, z: 21)
      when :crossed
        draw_crossed_dot(x: x, y: y, length: 2 * solid_dot_radius / 3,
          width: solid_dot_radius / 2, color: 'black', z: 22)
      when :crossed_circled
        draw_crossed_dot(x: x, y: y, length: 2 * solid_dot_radius / 3,
          width: solid_dot_radius / 2, color: 'black', z: 22)
        Circle.new(x: x, y: y, radius: circled_dot_radius, color: SOLID_DOT, z: 19)
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: BACKGROUND, z: 20)
      else
        Circle.new(x: x, y: y, radius: solid_dot_radius, color: EMPTY_DOT, z: 10)
      end
    end

    def draw_basepath(x1:, y1:, x2:, y2:, data:, even:)
      hash_length = 2 * basepath_width
      mid_x = (x1 + x2) / 2
      mid_y = (y1 + y2) / 2

      case data
      when :solid
        line_color = Color.new('black')
      when :hashed
        line_color = Color.new('black')
        if even
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
        if even
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
      Line.new(x1: x2, x2: x1, y1: y2, y2: y1,
        width: basepath_width, color: line_color, z: 18)
    end

    def draw_center_text(text)
      x = @left + (@width / 2)
      y = @top + (@height / 2)
      draw_text(x: x, y: y, data: text)
    end

    def draw_corner_text(text)
      x = @left + @width - (3 * solid_dot_radius)
      y = @top + @height - (3 * solid_dot_radius)
      draw_text(x: x, y: y, data: text)
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

    def draw_data_dots(balls:, strikes:, rbis:)
      dot_x = @left + (2 * solid_dot_radius)
      balls.each_with_index do |ball, i|
        dot_y = @top + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i)
        draw_dot(x: dot_x, y: dot_y, radius: solid_dot_radius, data: ball)
      end

      dot_x = @left + @width - (2 * solid_dot_radius)
      strikes.each_with_index do |strike, i|
        dot_y = @top + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i)
        draw_dot(x: dot_x, y: dot_y, radius: solid_dot_radius, data: strike)
      end

      dot_y = @left + @height - (2 * solid_dot_radius)
      rbis.times do |i|
        dot_x = @top + (2 * solid_dot_radius) + (2.5 * solid_dot_radius * i)
        Circle.new(x: dot_x, y: dot_y, radius: solid_dot_radius, color: SOLID_DOT, z: 10)
      end
    end

    def draw_diamond(bases:, paths:)
      t = @left + (@width / 2)
      dot_x = [t + diamond_radius, t, t - diamond_radius, t]
      t = @top + (@height / 2)
      dot_y = [t, t - diamond_radius, t, t + diamond_radius]

      4.times do |i|
        # The "first" basepath connects home (index 3) to first (index 0)
        x1 = dot_x[i]
        y1 = dot_y[i]
        x2 = dot_x[(i + 3) % 4]
        y2 = dot_y[(i + 3) % 4]

        draw_base(x: x1, y: y1, data: bases[i])
        draw_basepath(x1: x1, y1: y1, x2: x2, y2: y2, data: paths[i], even: i % 2 == 0)
      end
    end

    def draw_dot(x:, y:, radius:, data:)
      case data
      when :solid
        Circle.new(x: x, y: y, radius: radius, color: SOLID_DOT, z: 10)
      when :hollow
        Circle.new(x: x, y: y, radius: radius, color: SOLID_DOT, z: 10)
        Circle.new(x: x, y: y, radius: radius / 2, color: EMPTY_DOT, z: 11)
      when :crossed
        draw_crossed_dot(x: x, y: y, length: 2 * radius / 3, width: radius / 2, color: 'black', z: 12)
      else
        Circle.new(x: x, y: y, radius: radius, color: EMPTY_DOT, z: 10)
      end
    end

    def draw_outer_frame
      frame_radius = @scale
      Square.new(x: @left - frame_radius, y: @top - frame_radius,
        size: @height + (2 * frame_radius), color: 'black', z: 5)
      Square.new(x: @left + frame_radius, y: @top + frame_radius,
        size: @height - (2 * frame_radius), color: BACKGROUND, z: 6)
    end

    def draw_text(x:, y:, data:)
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
  end
end
