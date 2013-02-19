require "bundler/gem_tasks"
require 'highline'
require 'active_record'
require 'ccp_dbmodel'

Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb").each do |f| 
  require_relative f
end

desc 'Export fee break down by facility and year'
task :export, :facility_name, :year, :output_folder do |t, args|
  connection = setup_connection
           
  ActiveRecord::Base.establish_connection(connection)
  exporter = Childcarepro::DbExport::TaxReceipt::Exporter.new(args[:facility_name], args[:year].to_i)
  output_folder = args[:output_folder] || "./export" 
  @terminal.say @terminal.color("Exporting data to folder #{output_folder}...", :green)
  Childcarepro::DbExport::TaxReceipt::CSVwriter.new(output_folder).write(exporter.export)
end

def setup_connection
  config = Childcarepro.configuration
  @terminal = HighLine.new
  @terminal.say @terminal.color("Please choose the environment to use:", :blue)
  env = @terminal.choose(*config.environments.keys)
  instances = config.environments[env].instances
  if instances.size > 1
    @terminal.say @terminal.color("Please choose the instance to use for #{env}:", :blue)
    instance = @terminal.choose(*instances.keys)
  else
    instance = instances.keys[0]
    @terminal.say @terminal.color("Only available instance for #{env} is #{instance}", :blue)
  end
  
  @terminal.say @terminal.color("Connecting to #{env} - #{instance}", :green)
  config.environments[env].instance(instance)
end