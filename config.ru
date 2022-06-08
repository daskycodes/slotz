# frozen_string_literal: true

require 'bundler'
require 'active_support/time'
require File.expand_path('config/environment', __dir__)

Bundler.require

run Slotz::App
