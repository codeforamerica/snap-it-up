Rails.application.config.active_job.queue_adapter = :que

Que.log_formatter = proc do |data|
  unless :job_unavailable == data[:event]
    JSON.dump(data)
  end
end

Que.error_handler = proc do |error, job|
  Raven.capture_exception error
end
