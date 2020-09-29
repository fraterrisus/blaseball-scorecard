module API
  class Datablase
    require 'httparty'

    include HTTParty

    base_uri 'https://api.blaseball-reference.com/v1'
    logger ::Logger.new STDERR

    def get_game_events(gameId:)
      self.class.get('/events', query: { gameId: gameId })
    end

    def get_player_info(playerIds:)
      self.class.get('/playerInfo', query: { playerIds: Array(playerIds).join(',') })
    end
  end
end

