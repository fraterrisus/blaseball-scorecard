class Game
  require_relative 'api/chronicler'
  require_relative 'api/datablase'

  def initialize(game_id:)
    @game_id = game_id
    load_events
  end

  attr_reader :events, :game_id, :away_team_id, :home_team_id, :real_time, :day, :season, :weather

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

  def game_updates_page_call(after:)
    chronicler_api.get_game_updates_page(after: after, game: game_id, order: 'asc')
  end

  def load_events
    updates = game_updates_page_call(after:nil).parsed_response

    @events = []
    @real_time = updates.first['timestamp']
    @day = updates.first['data']['day']
    @season = updates.first['data']['season']
    @weather = updates.first['data']['weather']
    @away_team_id = updates.first['data']['awayTeam']
    @home_team_id = updates.first['data']['homeTeam']

    while updates.any?
      @events += updates.map do |update|
        update['data'].merge({ 'timestamp' => update['timestamp'] })
      end
      updates = game_updates_page_call(after: updates.last['timestamp'])
    end

    @events.sort_by! { |ev| ev['timestamp'] }
  end

  def get_lineup_for(team_id:, time:)
    team_events = team_events_call(team_id: team_id, time: time)
    lineup = team_events.first['data']['lineup']
    player_info = player_info_call(player_ids: lineup)
    lineup.map { |pid| player_info.select { |i| i['player_id'] == pid }.first }
  end

  def player_info_call(player_ids:)
    datablase_api.get_player_info(playerIds: player_ids).parsed_response
  end

  def team_events_call(team_id:, time:)
    chronicler_api.get_team_updates(before: time, team: team_id, count: 1, order: 'desc').
      parsed_response
  end
end
