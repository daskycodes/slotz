# frozen_string_literal: true

require 'spec_helper'
require_relative '../app/slot_finder'

describe 'Basic Slot Finder' do
  context 'attendees have no meetings' do
    let(:attendee1) { Slotz::Attendee.new(Faker::Name.name) }
    let(:attendee2) { Slotz::Attendee.new(Faker::Name.name) }
    let(:start_of_week) { Time.parse('2022-06-06 00:00:00 UTC') } # Monday
    let(:end_of_week) { Time.parse('2022-06-12 23:59:59 UTC') } # Sunday

    it 'should return a single slot since the start and end only fits into one timeslot' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 08:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      expect(slots.count).to eq(1)
      expect(slots.first[:start_time]).to eq(start_time)
      expect(slots.first[:end_time]).to eq(end_time)
    end

    it 'should return a single every slot of the week which fits an hour meeting in an interval of 15 minutes' do
      start_time = Time.parse('2022-06-06 00:00:00 UTC')
      end_time = Time.parse('2022-06-12 23:59:59 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      ##
      # 8 hours per day
      # 4 starts per hour
      # Last hour of the day will fit in 1
      # 5 days per week
      # (7 * 4 + 1) * 5 = 145
      expect(slots.count).to eq(145)
    end

    it 'should return a single every slot of the week which fits an half hour meeting in an interval of 15 minutes' do
      start_time = Time.parse('2022-06-06 00:00:00 UTC')
      end_time = Time.parse('2022-06-12 23:59:59 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 30.minutes.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      ##
      # 8 hours per day
      # 4 starts per hour
      # Last hour of the day will fit in 3
      # 5 days per week
      # (7 * 4 + 3) * 5 = 155
      expect(slots.count).to eq(155)
    end
  end

  context 'attendees have daily meetings in the morning' do
    let(:attendee1) { Slotz::Attendee.new(Faker::Name.name) }
    let(:attendee2) { Slotz::Attendee.new(Faker::Name.name) }
    let(:start_of_week) { Time.parse('2022-06-06 00:00:00 UTC') } # Monday
    let(:end_of_week) { Time.parse('2022-06-12 23:59:59 UTC') } # Sunday

    before do
      # Setup daily meetings for both attendees between 9 AM and 10 AM (Local Time)
      (start_of_week.to_date..end_of_week.to_date).each do |day|
        Slotz::Meeting.new([attendee1, attendee2], day.to_time.utc + 9.hours, day.to_time.utc + 10.hours)
      end
    end

    it 'should not return a slot when attendees have their morning meeting' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 08:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      expect(slots.count).to eq(0)
    end

    it 'should not return a slot when attendees have their morning meeting' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 08:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      expect(slots.count).to eq(0)
    end

    it 'should return a single every slot of the week which fits an hour without the morning meeting timeslots' do
      start_time = Time.parse('2022-06-06 00:00:00 UTC')
      end_time = Time.parse('2022-06-12 23:59:59 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      ##
      # 8 hours per day
      # 4 starts per hour
      # First hour of the day will fit in 0
      # Last hour of the day will fit in 1
      # 5 days per week
      # (6 * 4 + 1) * 5 = 125
      expect(slots.count).to eq(125)
    end

    it 'should not return a slot if there is a meeting scheduled in the given time range' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 08:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      expect(slots.count).to eq(0)
    end

    it 'should not return a slot if there is a meeting scheduled in the given time range and the time is not enough' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 08:59:59 UTC') # 1 second to 1 hour.
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots
      expect(slots.count).to eq(0)
    end
  end

  context 'attendees have separate meetings' do
    let(:attendee1) { Slotz::Attendee.new(Faker::Name.name) }
    let(:attendee2) { Slotz::Attendee.new(Faker::Name.name) }
    let(:start_of_week) { Time.parse('2022-06-06 00:00:00 UTC') } # Monday
    let(:end_of_week) { Time.parse('2022-06-12 23:59:59 UTC') } # Sunday

    before do
      (start_of_week.to_date..end_of_week.to_date).each do |day|
        # Setup daily meetings for both attendees between 9 AM and 10 AM (Local Time)
        Slotz::Meeting.new([attendee1, attendee2], day.to_time.utc + 9.hours, day.to_time.utc + 10.hours)

        case day.wday
        when 1..2
          Slotz::Meeting.new([attendee1], day.to_time.utc + 11.hours, day.to_time.utc + 12.hours)
          Slotz::Meeting.new([attendee2], day.to_time.utc + 12.hours, day.to_time.utc + 12.hours + 30.minutes)
        when 3..5
          Slotz::Meeting.new([attendee2], day.to_time.utc + 16.hours, day.to_time.utc + 17.hours)
        end
      end
    end

    it 'should return 2 slots for the given input' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 09:15:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots

      expect(slots.count).to eq(2)
      expect(slots[0][:start_time]).to eq(Time.parse('2022-06-06 08:00:00 UTC'))
      expect(slots[0][:end_time]).to eq(Time.parse('2022-06-06 09:00:00 UTC'))
      expect(slots[1][:start_time]).to eq(Time.parse('2022-06-06 08:15:00 UTC'))
      expect(slots[1][:end_time]).to eq(Time.parse('2022-06-06 09:15:00 UTC'))
    end

    it 'should return 0 slots when both attendees have a meeting' do
      start_time = Time.parse('2022-06-06 09:00:00 UTC')
      end_time = Time.parse('2022-06-06 10:30:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots

      expect(slots.count).to eq(0)
    end
  end
end
