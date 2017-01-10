require 'pp'

class DE_Optimizer

  class Domain
    attr_reader :min, :max
    def initialize(h)
      @min, @max = h[:min], h[:max]
      raise "invalid range : [#{@min}, #{@max}]" if @min > @max
    end

    def scale(r)    # give [0,1] value and return a value scaled in [min,max]
      r * (@max - @min) + @min
    end
  end

  attr_reader :best_point, :best_f, :t, :population
  attr_accessor :map_func

  def initialize( map_func, domains, n: nil, f: 0.8, cr: 0.9, rand_seed: nil )
    @n, @f, @cr = (n || domains.size*10), f, cr
    @rng = Random.new( rand_seed || Random.new_seed )

    @domains = domains.map {|h| Domain.new(h) }
    @map_func = map_func
    @t = 0
    @best_point = nil
    @best_f = Float::INFINITY

    generate_initial_points
  end

  def generate_initial_points
    @population = Array.new(@n) {|i| @domains.map {|d| d.scale( @rng.rand ) } }
    @current_fs = @map_func.call( @population )
  end

  def average_f
    @current_fs.inject(:+) / @current_fs.size
  end

  def proceed
    new_positions = []
    @n.times do |i|
      new_pos = generate_candidate(i)
      new_positions << new_pos
    end

    new_fs = @map_func.call( new_positions )

    # selection
    @n.times do |i|
      if new_fs[i] < @current_fs[i]
        @population[i] = new_positions[i]
        @current_fs[i] = new_fs[i]
        if new_fs[i] < @best_f
          @best_point = new_positions[i]
          @best_f = new_fs[i]
        end
      end
    end

    @t += 1
  end

  private

  # generate a candidate for @population[i]
  # based on DE/rand/1/binom algorithm
  def generate_candidate(i)
    # randomly pick a,b,c
    begin
      a = @rng.rand( @n )
    end while ( a == i )
    begin
      b = @rng.rand( @n )
    end while ( b == i || b == a )
    begin
      c = @rng.rand( @n )
    end while ( c == i || c == a || c == b )

    # compute the new position
    new_pos = @population[i].dup

    # pick a random index r
    dim = @domains.size
    r = @rng.rand( dim )

    dim.times do |d|
      if( d == r || @rng.rand < @cr )
        new_pos[d] = @population[a][d] + @f * (@population[b][d] - @population[c][d])
      end
    end
    new_pos
  end
end

if $0 == __FILE__
  domains = [
    {min: -10.0, max: 10.0},
    {min: -10.0, max: 10.0},
    {min: -10.0, max: 10.0}
  ]
  f = lambda {|x| (x[0]-1.0)**2+(x[1]-2.0)**2+(x[2]-3.0)**2 }
  map_agents = lambda {|points| points.map(&f) }

  opt = DE_Optimizer.new(map_agents, domains, n: 30, f: 0.8, cr: 0.9, rand_seed: 1234)

  20.times do |t|
    opt.proceed
    puts "#{opt.t} #{opt.best_point} #{opt.best_f} #{opt.average_f}"
  end
end

