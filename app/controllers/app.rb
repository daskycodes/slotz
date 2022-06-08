# frozen_string_literal: true

module Slotz
  ##
  # The `Slotz:App` class provides a high level API to find
  # available timeslots for a meeting for several attendees.
  #
  class App < Sinatra::Base
    before do
      content_type :json
    end

    get '/' do
      { message: 'Welcome to Slotz!' }.to_json
    end

    get '/attendees' do
      json(Attendee.all)
    end

  end
end
