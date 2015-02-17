worker_processes Integer(ENV["WEB_CONCURRENCY"] || 6)
timeout 45
preload_app true
