# frozen_string_literal: true

module Slotz
  ##
  # The `Slotz::SlotClassifier` is responsible for classifying an array of timeslots and
  # rank them by the following criteria:
  #
  # * Urgency: the earlier the slot, the better
  # * Focustime: if the meeting happens between 9am-11am (we can hardcode), it's better.
  #
  # We set the **current** best case scenario, the FOCUS_TIME_RANK to 0.5.
  class SlotClassifier
    FOCUS_TIME_RANK = 0.5

    ##
    # Returns a weighted and sorted array of timeslots
    def self.classify(timeslots)
      weighted_timeslots = timeslots.map do |timeslot|
        timeslot[:weight] = focus_time?(timeslot) ? FOCUS_TIME_RANK : FOCUS_TIME_RANK - rank_urgency(timeslot)
        timeslot
      end

      weighted_timeslots.sort_by do |timeslot|
        [-timeslot[:weight], timeslot[:start_time]]
      end
    end

    ##
    # TODO: Move to separate `Timeslot` model.
    #
    # Check whether the given timeslot is in the focus time (7AM UTC- 5PM UTC)
    # We check the total minutes from 0:00 UTC up to the point of 7AM and 5PM UTC
    # and compare them with the timeslots' times.
    #
    # Additionally we check if the start_time and end_time of the timeslot are on the same
    # day of the week. (Maybe there are cases where meetings are put in as blockers for several days like vacations)
    def self.focus_time?(timeslot)
      total_minutes(timeslot[:start_time]) >= 420 &&
        total_minutes(timeslot[:end_time]) <= 540 &&
        timeslot[:start_time].to_date == timeslot[:end_time].to_date
    end

    ##
    # Naive but fast???
    # This could at this stage be replaced by a simple sort_by date,
    # but we should still consider a weight value imo.
    def self.rank_urgency(timeslot)
      (total_minutes(timeslot[:start_time]).to_f / 10_000)
    end

    ##
    # Returns the total minutes from 0:00 UTC to the given time of the given date
    def self.total_minutes(date)
      hours = date.strftime('%H').to_i
      minutes = date.strftime('%M').to_i
      hours * 60 + minutes
    end
  end
end
