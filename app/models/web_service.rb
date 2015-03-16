# == Schema Information
#
# Table name: web_services
#
#  id               :integer          not null, primary key
#  pingometer_id    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  raw_monitor_data :jsonb
#

class WebService < ActiveRecord::Base
  has_many :monitor_incidents

  has_one :open_monitor_incident, -> { where(finished_at: nil).includes(:monitor_events).limit(1) }, class_name: 'MonitorIncident'

  def self.fetch_monitors
    Pingometer.new.monitors.map do |monitor|
      web_service = find_or_create_by! pingometer_id: monitor['id']
      web_service.raw_monitor_data = monitor
      web_service.save!
    end
  end

  def fetch_monitor
    self.raw_monitor_data = Pingometer.new.monitor pingometer_id
    save!
  end

  def monitor_url
    monitor = raw_monitor_data

    if monitor["hostname"] && !monitor["hostname"].empty?
      protocol = monitor['type'] && !monitor['type'].empty? ? monitor["type"] : "http"
      host = monitor["hostname"]
      path = monitor["path"] || ""
      query = monitor["querystring"] && !monitor["querystring"].empty? ? "?#{monitor["querystring"]}" : ""

      "#{protocol}://#{host}#{path}#{query}"
    else
      monitor["commands"]["1"]["get"]
    end
  end
end
