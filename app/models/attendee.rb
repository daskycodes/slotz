# frozen_string_literal: true

module Slotz
  class Attendee
    attr_accessor :name

    @@all = []

    def initialize(name)
      @name = name
      @@all << self
    end

    def self.all
      @@all
    end

    def self.find_by_names(names)
      all.filter { |attendee| names.include?(attendee.name) }
    end

    def as_json(_options = {})
      { name: @name }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
