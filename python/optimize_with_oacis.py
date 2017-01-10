import sys
import oacis
from de_optimizer import DE_Optimizer

if len(sys.argv) != 6:
    print("Usage: oacis_python optimize_with_oacis.py <num_iterations> <population size> <f> <cr> <seed>")
    raise RuntimeError("invalid number of arguments")

num_iter = int(sys.argv[1])
n = int(sys.argv[2])
f = float(sys.argv[3])
cr = float(sys.argv[4])
seed = int(sys.argv[5])
print("given parameters : num_iter %d, n: %d, f: %f, cr: %f, seed: %d" % (num_iter,n,f,cr,seed))

domains = [
    {'min': -10.0, 'max': 10.0},
    {'min': -10.0, 'max': 10.0}
]

sim = oacis.Simulator.find_by_name("de_optimize_test")
host = oacis.Host.find_by_name("localhost")

def map_agents(agents):
    parameter_sets = []
    for x in agents:
        ps = sim.find_or_create_parameter_set( {'p1':x[0], 'p2':x[1]} )
        runs = ps.find_or_create_runs_upto(1, submitted_to=host)
        print("Created a new PS: %s" % str(ps.id()) )
        parameter_sets.append(ps)
    w = oacis.OacisWatcher()
    w.watch_all_ps( parameter_sets, lambda x: None )  # Wait until all parameter_sets complete
    print("loop is called")
    w.loop()
    results = [ps.runs().first().result()['f'] for ps in parameter_sets]
    return results

opt = DE_Optimizer(map_agents, domains, n=n, f=f, cr=cr, rand_seed=seed)

for t in range(num_iter):
    opt.proceed()
    print("t=%d  %s, %f, %f" % (t, repr(opt.best_point), opt.best_f, opt.average_f() ) )
