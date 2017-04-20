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

logger = Logger.new($stderr)

domains = [
  {min: -10.0, max: 10.0},
  {min: -10.0, max: 10.0}
]

sim = Simulator.find_by_name("de_optimize_test")
host = Host.find_by_name("localhost")

map_agents = lambda {|agents|
  parameter_sets = agents.map do |x|
    ps = sim.find_or_create_parameter_set( p1:x[0], p2:x[1] )
    ps.find_or_create_runs_upto(1, submitted_to: host, host_param: host.default_host_parameters)
    logger.info "Created a new PS: #{ps.v}"
    ps
  end
  OacisWatcher::start( logger: logger ) {|w| w.await_all_ps( parameter_sets ) }
  parameter_sets.map {|ps| ps.runs.first.result["f"] }
}

opt = DE_Optimizer.new(map_agents, domains, n: n, f: f, cr: cr, rand_seed: 1234)

num_iteration.times do |t|
  opt.proceed
  puts "#{opt.t} #{opt.best_point} #{opt.best_f} #{opt.average_f}"
end

