class AtBat
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

  def to_s
    id
  end

  attr_reader :current_base, :id

  def advance_to(adjusted_base, type)
    base = adjusted_base - 1
    puts "#{id}#advance_to(#{ordinal(base)}, #{type})"

    (@current_base...base).each do |i|
      @paths[i+1] = path_type(type)
    end
    @bases[base] = base_type(type)

    if type == :walk
      @corner_text = 'BB'
    elsif type == :fielders_choice
      @corner_text = 'FC'
    end

    @current_base = base

    puts to_h
  end

  def ball
    @balls << :hollow
  end

  def caught_stealing(adjusted_base)
    base = adjusted_base - 1
    puts "#{id}#caught_stealing(#{ordinal(base)})"

    (@current_base...base).each do |i|
      @paths[i] = path_type(:caught_stealing)
    end
    @bases[base-1] = base_type(:caught_stealing)
    @out = true
  end

  def double_play
    @corner_text = '2P'
    @out = true
  end

  def fly_out_to(fielder_num)
    @center_text = [fielder_num.to_s, :circled]
    @out = true
  end

  def ground_out_to(fielder_num)
    @center_text = [fielder_num.to_s]
    @bases[0] = base_type(:out)
    @out = true
  end

  def out_at(adjusted_base)
    base = adjusted_base - 1
    puts "#{id}#out_at(#{ordinal(base)})"

    @bases[base] = base_type(:out)
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

  def triple_play
    @corner_text = '3P'
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

  def path_type(type)
    case type
    when :hit, :fielders_choice, :walk
      :solid
    when :stolen_base
      :hashed
    when :error
      :double_hashed
    when :caught_stealing
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
end
