class EventParser
  def initialize(events)
    @events = events
  end

  def parse
    inning = 0
    top_half = false
    batter_id = nil
    parsed_events = []
    @events.each do |raw_event|
      new_parsed_events = []

      if top_half
        away_batter = raw_event['awayBatter']
        if away_batter && away_batter != "" && away_batter != batter_id
          batter_id = away_batter
          new_parsed_events += [{ event: :start_of_at_bat, id: raw_event['awayBatter'],
            name: raw_event['awayBatterName'] }]
        end
      else
        home_batter = raw_event['homeBatter']
        if home_batter && home_batter != "" && home_batter != batter_id
          batter_id = home_batter
          new_parsed_events += [{ event: :start_of_at_bat, id: raw_event['homeBatter'],
            name: raw_event['homeBatterName'] }]
        end
      end

      new_parsed_events += case raw_event['lastUpdate']
      when 'Play ball!'
        []
      when 'Game over.'
        []
      when /\A(Top|Bottom) of (\d+), (.*) batting\.\z/
        []
      when /\A(.*) batting for the (.*)\.\z/
        []
      when /\ABall\./
        [{ event: :ball }]
      when /draws a walk\.\z/
        [
          { event: :ball },
          { event: :end_of_at_bat, type: :walk }
        ]
      when /\AStrike, (.*)\./
        [{ event: :strike, type: $1.downcase.to_sym }]
      when /\AFoul Ball\./
        [{ event: :strike, type: :foul_ball }]
      when /(strikes|struck) out (\w+)\.\z/
        [
          { event: :strike, type: $2.downcase.to_sym },
          { event: :end_of_at_bat, type: :strikeout }
        ]
      when /hit a (.*out) to (.+)\.\z/
        type, fielder = $1, $2
        [{ event: :end_of_at_bat, type: type.gsub(/\s/, '').to_sym, fielder_name: fielder }]
      when /hit into a (double play|triple play)!\z/
        [{ event: :end_of_at_bat, type: $1.gsub(/\s/, '_').to_sym }]
      when /on the sacrifice.\z/
        [{ event: :end_of_at_bat, type: :sacrifice }]
      when /hits a (\w+)!/
        [{ event: :end_of_at_bat, type: $1.downcase.to_sym }]
      when /hits a (solo home run|\d+-run home run|grand slam)!\z/
        [{ event: :end_of_at_bat, type: :home_run }]
      when /reaches on fielder's choice/
        [{ event: :end_of_at_bat, type: :fielders_choice }]
      when /(.*) gets caught stealing (\w*) base\./
        [{ event: :stolen_base, base: ordinal($2), success: false}]
      when /(.*) steals (\w*) base!/
        [{ event: :stolen_base, base: ordinal($2), success: true }]
      else
        STDERR.puts "Unrecognized update string: '#{raw_event['lastUpdate']}'"
        []
      end

      if top_half
        if raw_event['topOfInning'] == false
          top_half = false
          batter_id = nil
          new_parsed_events += [{ event: :start_of_inning, inning: inning, half: (top_half ? :top : :bottom) }]
        end
      else
        if raw_event['topOfInning'] == true
          top_half = true
          inning += 1
          batter_id = nil
          new_parsed_events += [{event: :start_of_inning, inning: inning, half: (top_half ? :top : :bottom) }]
        end
      end

      new_parsed_events.each do |ev|
        if ev[:event] == :end_of_at_bat
          batter_id = nil
        end
      end

      parsed_events += new_parsed_events
    end

    parsed_events
  end

  private

  def end_of_at_bat ; end

  def end_of_half_inning ; end

  def ordinal(word)
    case word
    when 'first'
      1
    when 'second'
      2
    when 'third'
      3
    when 'fourth'
      4
    when 'fifth'
      5
    else
      STDERR.print("Unrecognized base: '#{word}'")
    end
  end
end
