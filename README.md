# Samples of parameter optimization

This is a sample of parameter optimizations using OACIS watcher.
This program iteratively search for parameters which minimizes the results of the simulations.
For the optimization, we adopted a [differential evolutiion algorithm](https://en.wikipedia.org/wiki/Differential_evolution).

# Sample 1

Optimize the output of simulator having two input parameters "p1" and "p2".

## Prerequisites

Run the following command to register a simulator used in this sample on your OACIS.

```
export OACIS_ROOT=/path/to/your/oacis              # change the path to yours
${OACIS_ROOT}/bin/oacis_ruby prepare_simulator.rb
```

The registered simulator is as follows.

- Name: "de_optimize_test"
- Parameter Definitions:
    - "p1", Float, 0.0
    - "p2", Float, 0.0
- Command:
    - `ruby -r json -e 'j=JSON.load(File.read("_input.json")); f=(j["p1"]-1.0)**2+(j["p2"]-2.0)**2; puts({"f"=>f}.to_json)' > _output.json`
- Input type: JSON
- Executable_on : localhost


## What does this sample code do?

Search a pair of ("p1","p2") which minimizes the result of the simulations.

"ruby/de_optimizer.rb" is an optimization engine implementing a differential evolution algorithm. This is a generic routine independent of OACIS APIs.

"ruby/optimize_with_oacis.rb" combines OACIS and "de_optimizer.rb". It iteratively finds optimal parameters using the optimizer as a subroutine.

Similar codes written in Python are in "python" directory. You can use either Ruby or Python version of the code.

## How to run

Specify the parameters for Differential Evolution algorithm as command line arguments.

```sh
${OACIS_ROOT}/bin/oacis_ruby ruby/optimize_with_oacis.rb <num_iterations> <population size> <f> <cr> <seed>
```

For example, run the following.

```sh
${OACIS_ROOT}/bin/oacis_ruby ruby/optimize_with_oacis.rb 10 20 0.8 0.9 1234
```

Or, if you prefer Python script, run

```sh
${OACIS_ROOT}/bin/oacis_python python/optimize_with_oacis.py 10 20 0.8 0.9 1234
```

You can suspend the code by typing 'Ctrl-C'. Run the above command again to continue. The simulation runs already executed are stored in OACIS, and you can skip the finished runs.

A scatter plot of the sampled parameters would look like the following. Color scale indicates the simulation outputs.
As you see in the figure, region close to the optimal point is more intensively sampled.

![sample](scatter_plot.png)

One of the simplest ways to apply this code to your simulator would be to fork this repository on github, and edit "optimize_with_oacis.rb" or "optimize_with_oacis.py" such that it matches the specification of your simulator.

## Using "async", "await" methods

Since OACIS v2.13.0, `#async`, `#await_ps`, `#await_all_ps` methods are added to `OacisWatcher` class.
With these methods, we can make our code much simpler.
The samples using these methods are "ruby/optimize_with_oacis_async.rb" and "python/optimize_with_oacis_async.py".

To run one of these samples

```sh
${OACIS_ROOT}/bin/oacis_ruby ruby/optimize_with_oacis_async.rb 10 20 0.8 0.9 1234
```

```sh
${OACIS_ROOT}/bin/oacis_python python/optimize_with_oacis_async.py 10 20 0.8 0.9 1234
```

Although you might not find a significant difference from the previous codes, you will find an advantage of "async" and "await" in the next sample which is a bit more complicated.

# Sample 2

We consider a simulator which has three input parameters, "p1", "p2", and "p3".
We assume "p3" can take some discrete values `(1,2,3)`.
We are going to search a pair of ("p1","p2") which minimizes the result of the simulations for each value of "p3".

## Prerequisites

Run the following command to register a simulator on your OACIS.

```
${OACIS_ROOT}/bin/oacis_ruby prepare_simulator2.rb
```

The registered simulator named "de_optimize_test2" has three input parameters.

## How to run

To run the sample, run one of the following commands.

```sh
${OACIS_ROOT}/bin/oacis_ruby ruby/optimize2_with_oacis_async.rb 10 20 0.8 0.9 1234
```

```sh
${OACIS_ROOT}/bin/oacis_python python/optimize2_with_oacis_async.py 10 20 0.8 0.9 1234
```

If you read the code, you will realize that it is hard to write the code without "async" and "await".

# License

The MIT License (MIT)

Copyright (c) 2017 RIKEN, AICS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

