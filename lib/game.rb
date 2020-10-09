class Game
  require 'time'

  require_relative 'api/chronicler'
  require_relative 'api/datablase'

  def initialize(game_id:)
    @game_id = game_id
    load_events
  end

  attr_reader :events, :game_id, :away_team_id, :home_team_id, :real_time, :day, :season, :weather

  def our_lineup(top_half)
    if top_half
      lineups['away']
    else
      lineups['home']
    end
  end

  def their_lineup(top_half)
    if top_half
      lineups['home']
    else
      lineups['away']
    end
  end

  def lineups
    @lineups ||= {
      'away' => get_lineup_for(team_id: away_team_id, time: real_time),
      'home' => get_lineup_for(team_id: home_team_id, time: real_time),
    }
  end

  private

  def chronicler_api
    @chronicler_api ||= API::Chronicler.new
  end

  def datablase_api
    @datablase_api ||= API::Datablase.new
  end

  def game_events_call
    datablase_api.get_game_events(gameId: game_id).parsed_response
  end

  def game_updates_page_call(page: nil)
    chronicler_api.get_game_updates_page(game: game_id, order: 'asc', page: page)
  end

  def load_events
    updates = game_updates_page_call.parsed_response
    page = updates['nextPage']
    data = updates['data']

    @events = []
    @real_time = Time.parse(data.first['timestamp'])
    @day = data.first['data']['day']
    @season = data.first['data']['season']
    @weather = data.first['data']['weather']
    @away_team_id = data.first['data']['awayTeam']
    @home_team_id = data.first['data']['homeTeam']

    while data.any?
      @events += data.map do |datum|
        d = datum.merge(datum['data'])
        d['timestamp'] = Time.parse(d['timestamp'])
        d.delete('data')
        d
      end
      updates = game_updates_page_call(page: page)
      page = updates['nextPage']
      data = updates['data']
    end

    @events.sort_by! { |ev| ev['timestamp'] }
  end

  def get_lineup_for(team_id:, time:)
    team_events = team_events_call(team_id: team_id, time: time)
    lineup = team_events['data'].first['data']['lineup']
    player_info = player_info_call(player_ids: lineup)
    lineup.map { |pid| player_info.select { |i| i['player_id'] == pid }.first }
  end

  def player_info_call(player_ids:)
    datablase_api.get_player_info(playerIds: player_ids).parsed_response
  end

  def team_events_call(team_id:, time:)
    time = case time
    when String
      time
    when Time
      time.iso8601
    end
    chronicler_api.get_team_updates(before: time, team: team_id, count: 1, order: 'desc').
      parsed_response
  end
end

class GameFile < Game
  def initialize(events:, lineups:)
    @events = events
    @lineups = lineups
  end
end
