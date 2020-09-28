class API
  require_relative 'api/datablase'

  def initialize(game_id:)
    @game_id = game_id
  end

  def game_events
    game_events_response['results'].sort_by { |result| result['event_index'] }
  end

  private

  attr_reader :game_id

  def datablase
    @datablase ||= Datablase.new
  end

  def game_events_response
    @game_events_response ||= datablase.get_game_events(game_id: game_id).parsed_response
  end
end
