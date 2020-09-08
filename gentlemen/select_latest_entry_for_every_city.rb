class Event < Sequel::Model; end

module Gentlemen
  class SelectLatestEntryForEveryCity
    def self.call
      new.call
    end

    def call
      events = ::Event.
               where(created_at: whole_month).
               order(Sequel.desc(:created_at))
      events.uniq(&:city)
    end

    private

    def whole_month
      (start_of_month...end_of_month)
    end

    def start_of_month
      (Date.today - Date.today.mday + 1)
    end

    def end_of_month
      Date.new(Date.today.year, Date.today.month, -1)
    end
  end
end
