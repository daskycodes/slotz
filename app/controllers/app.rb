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

    get '/meetings' do
      json(Meeting.all)
    end

    ##
    # Find all the best timeslots
    #
    # JSON Body:
    # * attendees: array of names
    # * duration: duration in seconds
    # * start_time: ISO8601 start time
    # * end_time: ISO8601 end time
    #
    post '/slots/find' do
      @params = JSON.parse(request.body.read)
      attendees = Attendee.find_by_names(@params['attendees'])
      duration = @params['duration']
      start_time = @params['start_time']
      end_time = @params['end_time']

      slot_finder = Slotz::SlotFinder.new(attendees, duration, start_time, end_time)
      slots = slot_finder.find_slots

      json(SlotClassifier.classify(slots))
    end
  end
end
