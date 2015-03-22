Rails.application.config.active_job.queue_adapter = :que

Que.log_formatter = proc do |data|
  unless :job_unavailable == data[:event]
    JSON.dump(data)
  end
end
