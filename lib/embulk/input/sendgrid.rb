module Embulk
  module Input

    require 'json'
    require 'rest-client'

    class Sendgrid < InputPlugin
      Plugin.register_input("sendgrid", self)

      def self.transaction(config, &control)
        task = {
          api_key: config.param(:api_key, :string),
          start_date: config.param(:start_date, :string),
          end_date: config.param(:end_date, :string, default: '')
        }

        columns = [
          Column.new(0, 'date', :timestamp),
          Column.new(1, 'blocks', :long),
          Column.new(2, 'bounce_drops', :long),
          Column.new(3, 'bounces', :long),
          Column.new(4, 'clicks', :long),
          Column.new(5, 'deferred', :long),
          Column.new(6, 'delivered', :long),
          Column.new(7, 'invalid_emails', :long),
          Column.new(8, 'opens', :long),
          Column.new(9, 'processed', :long),
          Column.new(10, 'requests', :long),
          Column.new(11, 'spam_report_drops', :long),
          Column.new(12, 'spam_reports', :long),
          Column.new(13, 'unique_clicks', :long),
          Column.new(14, 'unique_opens', :long),
          Column.new(15, 'unsubscribe_drops', :long),
          Column.new(16, 'unsubscribes', :long),
        ]

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      def run
        json = RestClient.get("https://api.sendgrid.com/v3/stats?start_date=#{@task[:start_date]}&end_date=#{@task[:end_date]}", {:Authorization => "Bearer #{@task[:api_key]}", :content_type => 'application/json'})
        results = JSON.parse(json)

        results.each do |result|
          @page_builder.add(result["stats"].first["metrics"].values.unshift(Time.parse(result["date"])))
        end

        @page_builder.finish
      end
    end

  end
end
