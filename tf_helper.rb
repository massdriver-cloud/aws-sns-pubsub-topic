#! ruby

require 'json'

terraform_cmd = ARGV[0]

bundle_name = File.basename(__dir__)
schema_params = File.read("./schema-params.json")
params = JSON.parse(schema_params)

examples = params["examples"]
template_params_file = File.read("./src/dev.params.tfvars.json")

examples.each do |example|
  name = example.delete("__name")
  slug_safe_name = name.downcase.gsub(/[^a-z0-9]/, "")
  outfile = "/tmp/#{rand(10000000)}.params.tfvars.json"

  example_dev_params_file = template_params_file.gsub("PLACEHOLDER", slug_safe_name)
  example_dev_base_params = JSON.parse(example_dev_params_file)
  example_params = example_dev_base_params.merge(example)

  this_run_tfvars_json = File.open(outfile, "w+") do |f|
    f.puts JSON.pretty_generate(example_params)
  end

  plan_dir = "/tmp/massdriver/plans/#{bundle_name}"
  plan_path = "#{plan_dir}/#{slug_safe_name}.plan"
  
  var_files = "-var-file ./dev.connections.tfvars.json -var-file #{outfile}"

  cmd = [
    %Q{echo "Example: #{name}\n  Params: #{outfile}\n  Workspace: #{slug_safe_name}"},
    "mkdir -p #{plan_dir}",
    "cd ./src",
    "terraform workspace new #{slug_safe_name} || terraform workspace select #{slug_safe_name}"
  ]

  addl_cmds = {
    "plan" => [
      "terraform plan #{var_files}"
    ],
    "destroy" => [
      "terraform destroy #{var_files} -auto-approve"
    ],
    "apply" => [
      "terraform plan #{var_files} -out #{plan_path}",
      "terraform apply #{plan_path}"
    ]
  }

  cmd += (addl_cmds[terraform_cmd])

  puts `#{cmd.join(' && ')}`
end
