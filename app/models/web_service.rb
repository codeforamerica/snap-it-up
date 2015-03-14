# == Schema Information
#
# Table name: web_services
#
#  id            :integer          not null, primary key
#  pingometer_id :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class WebService < ActiveRecord::Base
  has_many :monitor_incidents
end
