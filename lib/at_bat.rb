class AtBat
  def initialize(id:)
    @current_base = 0

    @bases = [nil, nil, nil, nil]
    @paths = [nil, nil, nil, nil]
    @id = id
    @balls = []
    @strikes = []
    @rbis = 0
    @center_text = nil
    @corner_text = nil
  end

  attr_reader :current_base, :id

  def advance_to(base, type = :hit)
    puts "#{id}#advance_to(#{base},#{type})"

    (@current_base...base).each do |i|
      @paths[i] = path_type(type)
    end
    @bases[base-1] = base_type(type)
    @current_base = base
  end

  def ball
    @balls << :hollow
  end

  def strike(type)
    @strikes << strike_type(type)
  end

  def fly_out_to(fielder_num)
    @center_text = [fielder_num.to_s, :circled]
  end

  def ground_out_to(fielder_num)
    @center_text = [fielder_num.to_s]
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

  private

  def base_type(type)
    case type
    when :hit
      :solid
    when :fielders_choice
      :hollow
    when :out
      :crossed
    when :caught_stealing
      :crossed_circled
    else
      raise ArgumentError("Don't know what a '#{type}' base is'")
    end
  end

  def path_type(type)
    case type
    when :hit, :fielders_choice
      :solid
    when :stolen_base
      :hashed
    when :error
      :double_hashed
    when :caught_stealing
      nil
    else
      raise ArgumentError("Don't know what a '#{type}' path is'")
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
