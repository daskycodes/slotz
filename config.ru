# frozen_string_literal: true

require 'bundler'
require 'active_support/time'
require File.expand_path('config/environment', __dir__)

Bundler.require

run Slotz::App

# Seed some attendees
Slotz::Attendee.new('Daniel')
Slotz::Attendee.new('Rick')
Slotz::Attendee.new('Willem')

# Seed some meetings
start_of_week = Time.parse('2022-06-06 00:00:00 UTC')
end_of_week = Time.parse('2022-06-12 23:59:59 UTC')

# Setup daily meetings for all attendees between 9 AM and 10 AM (Local Time)
(start_of_week.to_date..end_of_week.to_date).each do |day|
  Slotz::Meeting.new(Slotz::Attendee.all, day.to_time.utc + 9.hours, day.to_time.utc + 10.hours)
end
