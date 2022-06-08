# frozen_string_literal: true

module Slotz
  class Meeting
    attr_accessor :attendees, :start_time, :end_time

    @@all = []

    def initialize(attendees, start_time, end_time)
      @attendees = attendees
      @start_time = start_time
      @end_time = end_time
      @@all << self
    end

    def self.all
      @@all
    end

    def self.for_attendees(attendees, start_time, end_time)
      Meeting.all.select do |meeting|
        meeting.attendees.any? { |attendee| attendees.include?(attendee) } &&
          meeting.start_time >= start_time &&
          meeting.end_time <= end_time
      end
    end

    def as_json(_options = {})
      {
        attendees: @attendees,
        start_time: @start_time.iso8601,
        end_time: @end_time.iso8601
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
