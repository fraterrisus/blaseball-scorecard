module API
  class Chronicler
    require 'httparty'

    include HTTParty

    base_uri 'https://reblase.sibr.dev/newapi'
    logger ::Logger.new STDERR

    def get_game_updates_page(**opts)
      query = allow_options(opts, :after, :before, :count, :day, :order, :game, :search)
      self.class.get('/games/updates', query: query)
    end

    def get_team_updates(**opts)
      query = allow_options(opts, :after, :before, :count, :order, :team)
      self.class.get('/teams/updates', query: query)
    end

    private

    def allow_options(from, *options)
      opts = {}
      options.each do |opt|
        opts[opt] = from[opt]
      end
      opts.compact
    end
  end
end
