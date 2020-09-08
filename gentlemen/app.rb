# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

DB = Sequel.sqlite("events.db")
DB.extension :date_arithmetic

DB.create_table?(:events) do
  primary_key :id
  String :city
  String :place
  String :address
  Time :time
  DateTime :created_at
  DateTime :updated_at
end

I18n.load_path << Dir[File.expand_path("locales") + "/*.yml"]
I18n.default_locale = :pl

Sequel::Model.plugin :timestamps
class Event < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence %i[city place time address]
    validates_schema_types %i[city place time address]
  end

  private

  def default_validation_helpers_options(type)
    case type
    when :presence
      { message: lambda { I18n.t("errors.presence") } }
    else
      super
    end
  end
end

ALLOWED_EMAILS = %w[michal.zajac@gmail.com].freeze

module Gentlemen
  class App < Roda
    plugin :render, engine: :slim
    plugin :sessions, secret: ENV.delete("GENTLEMEN_SESSION_SECRET")
    plugin :cookies
    plugin :route_csrf
    plugin :json_parser
    plugin :halt
    plugin :flash
    plugin :assets, css: ["app.css"], js: ["app.js"]
    plugin :public

    plugin :path
    path :root, "/"
    path :host, "/host"

    plugin :status_handler
    status_handler(403) do
      view("403")
    end

    route do |r|
      r.public
      r.assets

      r.root do
        if r.session["logged_in"]
          r.redirect host_path
        end

        view "homepage"
      end

      r.is "register" do
        r.post do
          access_token = r.params.dig("authResponse", "accessToken")

          return { success: false }.to_json unless access_token

          if access_token
            client = Koala::Facebook::API.new(access_token)
            profile = client.get_object("me", { fields: "first_name, last_name, email" })

            return { success: false }.to_json unless profile["email"]
            return { success: false }.to_json unless ALLOWED_EMAILS.include?(profile["email"])

            r.session["logged_in"] = true
            profile.merge(success: true).to_json
          end
        end
      end

      r.is "host" do
        r.get do
          unless r.session["logged_in"]
            flash["error"] = "Musisz się zalogować"
            r.redirect root_path
          end

          require_relative "./select_latest_entry_for_every_city"
          @declared_events = Gentlemen::SelectLatestEntryForEveryCity.call

          view "host"
        end

        r.post do
          check_csrf!

          columns = Event.columns[0...-2].map(&:to_s)
          event_params = r.params.slice(*columns)
          event = Event.new(event_params)

          if event.valid?
            event.save
            flash["info"] = "Dodałeś wydarzenie dla miasta #{event.city} o godz. #{event.time.strftime('%H:%M')} w miejscu #{event.place}"
          else
            flash["error"] = "Coś poszło nie tak, komunikaty poniżej powinny Ci pomóc rozwiązać problem."
            event.errors.each do |key, value|
              flash[key] = "#{key} #{value.join(',')}"
            end
          end

          r.redirect host_path
        end
      end
    end
  end
end
