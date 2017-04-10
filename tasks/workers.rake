namespace :workers do
  desc "Schedule and work, so we only need 1 dyno"
  task :schedule_and_work do
    if Process.fork
      sh "que --worker-count 1 ./app.rb"
    else
      sh "clockwork job_schedule.rb"
      Process.wait
    end
  end
end
