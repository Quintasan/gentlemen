#!/usr/bin/env ruby
# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "sequel"
require "pry"

DB = Sequel.sqlite("events.db")
class Event < Sequel::Model; end

pry
