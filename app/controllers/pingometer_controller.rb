class PingometerController < ApplicationController
  def webhook
    render json: { '200' => 'Ok' }
  end
end
