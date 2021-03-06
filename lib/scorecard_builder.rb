class ScorecardBuilder
  def initialize(game, events)
    @game = game
    @events = events

    @game_at_bats = []
    @game_score = []
    @current_inning = 0
    @current_half_inning = nil
    @current_at_bats = []
    @current_runners = {}
    @inning_at_bats = []
    @current_score = 0

    @events.each do |ev|
      puts ev
      self.send(ev[:event], ev)
      puts "  #{@current_at_bats.map(&:to_s)}"
    end

    finish_inning
  end

  attr_reader :game_at_bats, :game_score

  private

  # events

  def ball(ev)
    hitter.ball
  end

  def end_of_at_bat(ev)
    hitter.rbis = ev[:runs] - @current_score
    new_runners = ev[:runner_ids]
    case ev[:type]
    when :strikeout
      hitter.strikeout
    when :flyout
      fielder_index = find_fielder(@current_half_inning, ev[:fielder_name])
      hitter.fly_out_to(fielder_index)
    when :groundout
      fielder_index = find_fielder(@current_half_inning, ev[:fielder_name])
      hitter.ground_out_to(fielder_index)
      @current_at_bats[0] = nil
      if ev[:outs] != 0 # wraps around to 0 immediately after the 3rd out
        diff_runners(new_runners)
      end
    when :double_play
      hitter.double_play
      diff_runners(new_runners, :out)
    when :triple_play
      hitter.triple_play
      diff_runners(new_runners, :out)
    when :fielders_choice
      diff_runners(new_runners, :fielders_choice)
    when :walk
      diff_runners(new_runners, :walk)
    when :single, :double, :triple, :home_run
      diff_runners(new_runners)
    when :sacrifice
      hitter.sacrifice
      @current_at_bats[0] = nil
      diff_runners(new_runners)
    else
      raise 'Unrecognized event type!'
    end
    @current_runners = new_runners
    @current_at_bats[0] = nil
  end

  def start_of_at_bat(ev)
    raise 'Home plate is occupied!' unless hitter.nil?
    new_at_bat = PlateAppearance.new(id: ev[:id])
    @current_at_bats[0] = new_at_bat
    @inning_at_bats << new_at_bat
    @current_score = ev[:runs]
  end

  def start_of_inning(ev)
    finish_inning
    @inning_at_bats = []
    @current_inning = ev[:inning]
    @current_half_inning = ev[:half]
    @current_at_bats = [ nil, nil, nil, nil ]
  end

  def stolen_base(ev)
    new_runners = ev[:runner_ids]
    if ev[:success]
      runner_on(ev[:base]-1).advance_to(ev[:base], :stolen_base)
      @current_at_bats[ev[:base]] = @current_at_bats[ev[:base]-1]
      @current_at_bats[ev[:base]-1] = nil
    else
      runner_on(ev[:base]-1).caught_stealing(ev[:base])
    end
    @current_runners = new_runners
  end

  def strike(ev)
    hitter.strike(ev[:type])
  end

  # helpers

  def hitter
    @current_at_bats[0]
  end

  # 0 = home
  def runner_on(base)
    @current_at_bats[base]
  end

  # Top 3, flyout to Dominic Marijuana doesn't find him
  def find_fielder(current_half_inning, fielder_name)
    idx = @game.their_lineup(current_half_inning == :top).index do |p|
      p['player_name'] == fielder_name
    end
    idx ? idx + 1 : 0
  end

  def finish_inning
    if @inning_at_bats.any?
      @game_at_bats[@current_inning - 1] ||= {}
      @game_at_bats[@current_inning - 1][@current_half_inning] = @inning_at_bats
      @game_score[@current_inning - 1] ||= {}
      @game_score[@current_inning - 1][@current_half_inning] = @current_score
    end
  end

  def diff_runners(new, type = :hit)
    prev_at_bats = @current_at_bats
    new_at_bats = [nil, nil, nil, nil]
    prev_at_bats.each_with_index do |runner, prev_base|
      next if runner.nil?
      #runner = prev_at_bats[prev_base+1] # incoming base IDs are -1 based; array index is 0-based
      #raise "Runner mismatch at base #{prev_base+1}, expected #{id}, found #{runner.id}" unless id == runner.id
      new_base = new[runner.id]
      if new_base.nil? && type == :hit
        new_base = 3
      end
      if new_base.nil?
        runner.out_at(prev_base + 1)
      else
        if (type == :walk || type == :fielders_choice) && runner != hitter
          runner.advance_to(new_base+1, :hit)
        else
          runner.advance_to(new_base+1, type)
        end
        new_at_bats[new_base+1] = runner unless new_base == 3
      end
    end
    if type == :stolen_base
      new_at_bats[0] = prev_at_bats[0]
    end
    @current_at_bats = new_at_bats
  end
end
