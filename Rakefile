require "bundler/gem_tasks"
require 'highline'
require 'active_record'
require 'ccp_dbmodel'
require 'mail'

Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb").each do |f| 
  require_relative f
end

desc 'Export tax receipts facility and year'
task :export, :facility_name, :year, :output_folder do |t, args|
  connection = setup_connection         
  ActiveRecord::Base.establish_connection(connection)
  
  e = Childcarepro::DbExport::TaxReceipt::Exporter.new(args[:year].to_i, @terminal, {facility_name: args[:facility_name]})
  run_export(e, args[:output_folder])
end

desc 'Export tax receipts for all facilities'
task :export_all,:year, :env,:output_folder do |t, args|
  Childcarepro::DbExport::DatabaseEnumerator.new(Childcarepro.configuration.environments[args[:env].to_sym].instances).each_instance do
      Childcarepro::DbExport::TaxReceipt::Exporter.exporters(args[:year].to_i, HighLine.new).each { |e|
          run_export(e, args[:output_folder])
      }
  end
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

def run_export(exporter, output_folder, send_mail=true)
  writers =[ Childcarepro::DbExport::TaxReceipt::CSVwriter.new(output_folder||'./export'),
    Childcarepro::DbExport::TaxReceipt::PdfWriter.new(output_folder||'./export')]
  receipts= exporter.export
  
  facility_folder = writers.map { |w| w.write(receipts) }.last
  Childcarepro::DbExport::ReceiptMailer.sendReceipts(receipts.email, facility_folder) if send_mail
end