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
          Column.new(1, 'category', :string),
          Column.new(2, 'blocks', :long),
          Column.new(3, 'bounce_drops', :long),
          Column.new(4, 'bounces', :long),
          Column.new(5, 'clicks', :long),
          Column.new(6, 'deferred', :long),
          Column.new(7, 'delivered', :long),
          Column.new(8, 'invalid_emails', :long),
          Column.new(9, 'opens', :long),
          Column.new(10, 'processed', :long),
          Column.new(11, 'requests', :long),
          Column.new(12, 'spam_report_drops', :long),
          Column.new(13, 'spam_reports', :long),
          Column.new(14, 'unique_clicks', :long),
          Column.new(15, 'unique_opens', :long),
          Column.new(16, 'unsubscribe_drops', :long),
          Column.new(17, 'unsubscribes', :long),
        ]

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      def run
        max_category_limit = 100

        date = Date.parse(@task[:start_date])
        end_date = @task[:end_date] != "" ? Date.parse(@task[:end_date]) : Date.today

        while date <= end_date do
          json = RestClient.get("https://api.sendgrid.com/v3/categories/stats/sums?start_date=#{date.strftime("%Y-%m-%d")}&limit=#{max_category_limit}", {:Authorization => "Bearer #{@task[:api_key]}", :content_type => 'application/json'})
          results = JSON.parse(json)

          results["stats"].each do |metrics|
            @page_builder.add(metrics["metrics"].values.unshift(metrics["name"]).unshift(Time.parse(results["date"])))
          end

          date = date.next_day
        end

        @page_builder.finish
      end
    end

  end
end
