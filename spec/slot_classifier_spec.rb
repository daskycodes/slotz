# frozen_string_literal: true

require 'spec_helper'
require_relative '../app/slot_classifier'

describe 'Basic Slot Classifier' do
  context 'attendees have no meetings' do
    let(:attendee1) { Slotz::Attendee.new(Faker::Name.name) }
    let(:attendee2) { Slotz::Attendee.new(Faker::Name.name) }
    let(:start_of_week) { Time.parse('2022-06-06 00:00:00 UTC') } # Monday
    let(:end_of_week) { Time.parse('2022-06-12 23:59:59 UTC') } # Sunday

    it 'should rank focus time slots first and latest slot last' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 15:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots

      classified_slots = Slotz::SlotClassifier.classify(slots)

      expect(classified_slots.first[:start_time]).to eq(start_time)
      expect(classified_slots.last[:end_time]).to eq(end_time)
    end

    it 'should rank focus time slots with weight 0.5' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 09:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots

      classified_slots = Slotz::SlotClassifier.classify(slots)

      expect(classified_slots.first[:weight]).to eq(0.5)
      expect(classified_slots.last[:weight]).to eq(0.5)
    end
  end

  context 'attendees have focus time blocked' do
    let(:attendee1) { Slotz::Attendee.new(Faker::Name.name) }
    let(:attendee2) { Slotz::Attendee.new(Faker::Name.name) }
    let(:start_of_week) { Time.parse('2022-06-06 00:00:00 UTC') } # Monday
    let(:end_of_week) { Time.parse('2022-06-12 23:59:59 UTC') } # Sunday

    before do
      # Setup daily meetings for both attendees between 9 AM and 10 AM (Local Time)
      (start_of_week.to_date..end_of_week.to_date).each do |day|
        Slotz::Meeting.new([attendee1, attendee2], day.to_time.utc + 9.hours, day.to_time.utc + 11.hours)
      end
    end

    it 'should rank focus time slots with weight 0.5' do
      start_time = Time.parse('2022-06-06 07:00:00 UTC')
      end_time = Time.parse('2022-06-06 09:00:00 UTC')
      slot_finder = Slotz::SlotFinder.new([attendee1, attendee2], 1.hour.to_i, start_time, end_time)
      slots = slot_finder.find_slots

      classified_slots = Slotz::SlotClassifier.classify(slots)

      expect(classified_slots).to eq([])
    end
  end
end
