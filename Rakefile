require "bundler/gem_tasks"
require 'highline'
require 'active_record'
require 'ccp_dbmodel'
require 'mail'

Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb").each do |f| 
  require_relative f
end

@logger = Logger.new('logfile.log')

desc 'Export tax receipts facility and year'
task :export, :facility_name, :year, :output_folder do |t, args|
  connection = setup_connection         
  ActiveRecord::Base.establish_connection(connection)
  
  e = Childcarepro::DbExport::TaxReceipt::Exporter.new(args[:year].to_i, @terminal, {facility_name: args[:facility_name]})
  run_export(e, args[:output_folder])
end

desc 'Export tax receipts for all facilities'
task :all,:year, :env,:output_folder do |t, args|
  Childcarepro::DbExport::DatabaseEnumerator.new(Childcarepro.configuration.environments[args[:env].to_sym].instances).each_instance do
      @logger.info("Task started.")
      @logger.info("params: #{args.year}, #{args.env}, #{args.output_folder}:")
      exporters =Childcarepro::DbExport::TaxReceipt::Exporter.exporters(args[:year].to_i, HighLine.new)
      exporters=exporters.slice(ENV["FROM"]..(ENV["TO"]||1000)) if ENV["FROM"]
      exporters.each { |e|
          run_export(e, args[:output_folder])
          e=nil
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

def run_export(exporter, output_folder)
  writers =[ Childcarepro::DbExport::TaxReceipt::CSVwriter.new(output_folder||'./export'),
    Childcarepro::DbExport::TaxReceipt::PdfWriter.new(output_folder||'./export')]
  @logger.info("start exporting #{exporter.facility.FACILITYNAME}")
  begin
      receipts= exporter.export
      @logger.info("writing files to #{output_folder}")
      facility_folder = writers.map { |w| w.write(receipts) }.last
      if !ENV["DONT_EMAIL"]=~/true/i then
          @logger.info("sending email to #{ENV["EMAIL_TO"] ||receipts.email}") 
          Childcarepro::DbExport::ReceiptMailer.sendReceipts(receipts.email, facility_folder) 
      end
      
      receipts = nil
  rescue => e
    @logger.error e.message
    @logger.error e.backtrace
  end
end