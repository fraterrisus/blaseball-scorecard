class PlateAppearance
  def initialize(id:)
    @current_base = -1

    @bases = [nil, nil, nil, nil]
    @paths = [nil, nil, nil, nil]
    @id = id
    @balls = []
    @strikes = []
    @rbis = 0
    @center_text = nil
    @corner_text = nil
    @out = false
  end

  ##### ##### ##### ##### #####

  attr_reader :id

  def current_base
    @current_base + 1
  end

  def out?
    @out
  end

  def rbis=(rbis)
    @rbis = rbis
  end

  def to_h
    {
      bases: @bases,
      paths: @paths,
      balls: @balls,
      strikes: @strikes,
      rbis: @rbis,
      center_text: @center_text,
      corner_text: @corner_text
    }.compact
  end

  def to_s
    id
  end

  ##### ##### ##### ##### #####

  def advance_to(adjusted_base, type)
    base = adjusted_base - 1
    puts "#{id}#advance_to(#{ordinal(base)}, #{type})"

    update_bases_and_paths(base, type)
    update_corner_text(type)
    @current_base = base

    puts to_h
  end

  def ball
    @balls << :hollow
  end

  def caught_stealing(adjusted_base)
    base = adjusted_base - 1
    puts "#{id}#caught_stealing(#{ordinal(base)})"
    update_bases_and_paths(base, :caught_stealing)
    @out = true
  end

  def double_play
    update_corner_text('2P')
    @out = true
  end

  def fly_out_to(fielder_num)
    @center_text = [fielder_num.to_s, :circled]
    @out = true
  end

  def ground_out_to(fielder_num)
    @center_text = [fielder_num.to_s]
    update_bases_and_paths(0, :out)
    @out = true
  end

  def out_at(adjusted_base)
    base = adjusted_base - 1
    puts "#{id}#out_at(#{ordinal(base)})"
    update_bases_and_paths(base, :out)
    @out = true
  end

  def sacrifice
    @center_text = [:squared]
    @out = true
  end

  def strike(type)
    @strikes << strike_type(type)
  end

  def strikeout
    @center_text = if @strikes.last == :hollow
      ['K', :reversed]
    else
      'K'
    end
    @out = true
  end

  def triple_play
    update_corner_text('3P')
    @out = true
  end

  private

  def base_type(type)
    case type
    when :hit, :stolen_base
      :solid
    when :fielders_choice, :walk
      :hollow
    when :out
      :crossed
    when :caught_stealing
      :crossed_circled
    else
      raise(ArgumentError, "Don't know what a '#{type}' base is'")
    end
  end

  def ordinal(base)
    case base
    when 0
      'first'
    when 1
      'second'
    when 2
      'third'
    when 3
      'home'
    else
      raise(ArgumentError, "Don't recognize base #{base}")
    end
  end

  def corner_text_type(type)
    case type
    when :walk
      'BB'
    when :fielders_choice
      'FC'
    when :error
      'E'
    else
      nil
    end
  end

  def path_type(type)
    case type
    when :hit, :fielders_choice, :walk
      :solid
    when :stolen_base
      :hashed
    when :error
      :double_hashed
    when :caught_stealing, :out
      nil
    else
      raise(ArgumentError, "Don't know what a '#{type}' path is'")
    end
  end

  def strike_type(type)
    case type
    when :swinging
      :solid
    when :looking
      :hollow
    when :foul_ball
      :crossed
    else
      raise ArgumentError("Don't know what a '#{type}' strike is'")
    end
  end

  def update_bases_and_paths(base, type)
    (current_base..base).each do |i|
      @paths[i] = path_type(type)
    end
    @bases[base] = base_type(type)
  end

  def update_corner_text(type)
    case type
    when String
      @corner_text = type
    when Symbol
      # Allow a new update to overwrite what's there, but if the value is nil, retain what we had
      @corner_text = corner_text_type(type) || @corner_text
    end
  end
end
