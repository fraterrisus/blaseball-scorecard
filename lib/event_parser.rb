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
        [] # [{ event: :end_of_game }]
      when /\A(Top|Bottom) of (\d+), (.*) batting\.\z/
        []
      when /\A(.*) batting for the (.*)\.\z/
        []
      when /\ABall\./
        [{ event: :ball }]
      when /draws a walk\.\z/
        [
          { event: :ball },
          { event: :end_of_at_bat, type: :walk, outs: raw_event['halfInningOuts'] }
        ]
      when /\AStrike, (.*)\./
        [{ event: :strike, type: $1.downcase.to_sym }]
      when /\AFoul Ball\./
        [{ event: :strike, type: :foul_ball }]
      when /(strikes|struck) out (\w+)\.\z/
        [
          { event: :strike, type: $2.downcase.to_sym },
          { event: :end_of_at_bat, type: :strikeout, outs: raw_event['halfInningOuts'] }
        ]
      when /hit a (.*out) to (.+)\.\z/
        type, fielder = $1, $2
        [{ event: :end_of_at_bat, type: type.gsub(/\s/, '').to_sym, fielder_name: fielder,
          outs: raw_event['halfInningOuts'] }]
      when /hit into a (double play|triple play)!\z/
        puts raw_event
        [{ event: :end_of_at_bat, type: $1.gsub(/\s/, '_').to_sym, outs: raw_event['halfInningOuts'] }]
      when /on the sacrifice.\z/
        [{ event: :end_of_at_bat, type: :sacrifice, outs: raw_event['halfInningOuts'] }]
      when /hits a (\w+)!/
        [{ event: :end_of_at_bat, type: $1.downcase.to_sym, outs: raw_event['halfInningOuts'] }]
      when /hits a (solo home run|\d+-run home run|grand slam)!\z/
        [{ event: :end_of_at_bat, type: :home_run, outs: raw_event['halfInningOuts'] }]
      when /reaches on fielder's choice.*out at (\w+) base/
        [{ event: :end_of_at_bat, type: :fielders_choice, base: ordinal($1),
          outs: raw_event['halfInningOuts'] }]
      when /(.*) gets caught stealing (\w*) base\./
        [{ event: :stolen_base, base: ordinal($2), success: false, outs: raw_event['halfInningOuts'] }]
      when /(.*) steals (\w*) base!/
        [{ event: :stolen_base, base: ordinal($2), success: true, outs: raw_event['halfInningOuts'] }]
      else
        STDERR.puts "Unrecognized update string: '#{raw_event['lastUpdate']}'"
        []
      end

      if top_half
        if raw_event['topOfInning'] == false
          top_half = false
          batter_id = nil
          new_parsed_events += [{ event: :start_of_inning, inning: inning, half: :bottom }]
        end
      else
        if raw_event['topOfInning'] == true
          top_half = true
          inning += 1
          batter_id = nil
          new_parsed_events += [{ event: :start_of_inning, inning: inning, half: :top }]
        end
      end

      new_parsed_events.each do |ev|
        ev[:runner_ids] = raw_event['baseRunners'].zip(raw_event['basesOccupied']).to_h

        if ev[:event] == :end_of_at_bat
          batter_id = nil
        end
      end

      parsed_events += new_parsed_events
    end

    parsed_events
  end

  private

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
