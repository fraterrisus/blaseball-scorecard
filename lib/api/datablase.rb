class API
  class Datablase
    require 'httparty'

    include HTTParty

    base_uri 'https://api.blaseball-reference.com/v1'

    def get_game_events(game_id:)
      self.class.get('/events', query: { gameId: game_id })
    end

    def get_player_info(player_ids:)
      self.class.get('/playerInfo', query: { playerIds: Array(player_ids).join(',') })
    end


  end
end

