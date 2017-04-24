require_relative "de_optimizer"

# parsing inputs
unless ARGV.size == 5
  $stderr.puts "Usage: ruby #{__FILE__} <num_iterations> <population size> <f> <cr> <seed>"
  raise "invalid arguments"
end
num_iteration = ARGV[0].to_i
n = ARGV[1].to_i
f = ARGV[2].to_f
cr = ARGV[3].to_f
seed = ARGV[4].to_i

opt_param = {num_iteration:num_iteration, n:n, f:f, cr:cr, seed:seed}
logger = Logger.new($stderr)


def optimize_p1p2( p3, opt_param )
  sim = Simulator.find_by_name("de_optimize_test2")
  host = Host.find_by_name("localhost")
  domains = [
    {min: -10.0, max: 10.0},
    {min: -10.0, max: 10.0}
  ]

  map_agents = lambda {|agents|
    parameter_sets = agents.map do |x|
      ps = sim.find_or_create_parameter_set( p1:x[0], p2:x[1], p3: p3 )
      ps.find_or_create_runs_upto(1, submitted_to: host, host_param: host.default_host_parameters)
      $stderr.puts "Created a new PS: #{ps.v}"
      ps
    end
    parameter_sets = OacisWatcher.await_all_ps( parameter_sets )
    parameter_sets.map {|ps| ps.runs.first.result["f"] }
  }

  opt = DE_Optimizer.new(map_agents, domains,
                         n: opt_param[:n], f: opt_param[:f], cr: opt_param[:cr], rand_seed: opt_param[:seed])

  opt_param[:num_iteration].times do |t|
    opt.proceed
    puts "#{opt.t} #{opt.best_point} #{opt.best_f} #{opt.average_f}"
  end
end

OacisWatcher::start( logger: logger ) {|w|
  p3_list = [0.0,1.0,2.0]
  p3_list.each do |p3|
    OacisWatcher.async {
      optimize_p1p2( p3, opt_param )
    }
  end
}
