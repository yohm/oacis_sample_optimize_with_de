if sim = Simulator.where(name: "de_optimize_test").first
  $stderr.puts "already Simulator '#{sim.name}' exists. Deleting this."
  sim.discard
end

command = <<EOS.chomp
ruby -r json -e 'j=JSON.load(File.read("_input.json")); f=(j["p1"]-1.0)**2+(j["p2"]-2.0)**2; puts({"f"=>f}.to_json)' > _output.json
EOS

sim = Simulator.create!(
  name: "de_optimize_test",
  parameter_definitions: [
    ParameterDefinition.new(key: "p1", type: "Float", default: 0.0),
    ParameterDefinition.new(key: "p2", type: "Float", default: 0.0)
  ],
  command: command,
  executable_on: [Host.where(name: "localhost").first]
)
$stderr.puts "A new simulator #{sim.id} is created."

