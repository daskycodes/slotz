# frozen_string_literal: true

module Slotz
  ##
  # The `Slotz::SlotFinder` will find all available timeslots for the given attendees,
  # the duration, start_time and end_time.
  class SlotFinder
    def initialize(attendees, duration, start_time, end_time)
      @attendees = attendees
      @duration = duration
      @start_time = start_time
      @end_time = end_time
      @meetings = list_meetings
      @timeslots = considered_slots
    end

    ##
    # Returns an array of possible timeslots considering the attendees' meetings.
    #
    # The returned slots are not blocked by any meetings and are in the requests
    # start_time and end_time range.
    #
    # @return [Array]
    #
    # ## Example
    #     [
    #       {
    #         start_time: 2022-06-07 00:00:00 +0000,
    #         end_time: 2022-06-08 00:00:00 +0000
    #       },
    #       ...
    #     ]
    def find_slots
      @timeslots.filter do |slot|
        @meetings.none? do |meeting|
          (slot[:start_time] < meeting.end_time) and (meeting.start_time < slot[:end_time])
        end &&
          ((slot[:start_time] >= @start_time) and (slot[:end_time] <= @end_time))
      end
    end

    ##
    # List all meetings for the attendees in the given start_time and end_time.
    def list_meetings
      Meeting.for_attendees(@attendees, @start_time, @end_time)
    end

    ##
    # Returns an array of possible timeslots without considering any meetings.
    #
    # @return [Array]
    #
    # ## Example
    #     [
    #       {
    #         start_time: 2022-06-07 00:00:00 +0000,
    #         end_time: 2022-06-08 00:00:00 +0000
    #       },
    #       ...
    #     ]
    def considered_slots
      timeslots = []

      (@start_time.to_date..@end_time.to_date).each do |date|
        # Reject days which are not on a weekday.
        next unless date.on_weekday?

        # Start at 9 AM UTC and end at 7 PM UTC.
        # This is hardcoded but should be refactored to use the user's
        # preferred availabilty. Availability could be a model which
        # belongs to a specific Attendee
        possible_start = date.to_time.utc + 9.hours
        end_of_workday = date.to_time.utc + 17.hours

        # Add all possible timeslots in a 15 minute interval to the
        # timeslots array as hash maps with the `start_time` and `end_time`.
        loop do
          timeslots << {
            start_time: possible_start,
            end_time: possible_start + @duration
          }

          possible_start += 15.minutes
          break if possible_start + @duration > end_of_workday
        end
      end

      timeslots.flatten
    end
  end
end
