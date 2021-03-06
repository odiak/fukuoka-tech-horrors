dir = File.absolute_path(File.dirname(__FILE__))

worker_processes 2
working_directory dir

timeout 300
listen "#{dir}/unicorn.sock"
pid "#{dir}/unicorn.pid"

stderr_path "#{dir}/unicorn.stderr.log"
stdout_path "#{dir}/unicorn.stdout.log"
