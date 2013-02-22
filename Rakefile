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
      @logger.info("params: #{args.year}, #{args.env}, #{args.output_folder},ENV['DEBUG']=#{ENV['DEBUG']} ENV[EMAIL_TO]=#{ENV['EMAIL_TO']} ENV['DONT_EMAIL']=#{ENV['DEBUG']}")
      @logger.info("env: ENV['DEBUG']=#{ENV['DEBUG']} ENV['EMAIL_TO']=#{ENV['EMAIL_TO']} ENV['DONT_EMAIL']=#{ENV['DONT_EMAIL']} ENV['FROM']=#{ENV['FROM']} ENV['TO']=#{ENV['TO']}")
      
      Childcarepro::DbExport::TaxReceipt::Exporter.each_exporter(args[:year].to_i, HighLine.new) do |exporter, idx|
            @logger.info("start exporting #{exporter.facility.FACILITYNAME}")
            begin
              if idx.between?((ENV["FROM"]||0),(ENV["TO"]||1000)) then
                 @logger.info("start exporting #{idx}-#{exporter.facility.FACILITYNAME}")
                 run_export(exporter, args[:output_folder]) 
              end
            rescue => e
              @logger.error e.message
              @logger.error e.backtrace
            end
      end
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

      receipts= exporter.export
      @logger.info("writing files to #{output_folder}")
      facility_folder = writers.map { |w| w.write(receipts) }.last
      @logger.info("sending email to #{ENV["EMAIL_TO"] ||receipts.email}") unless ENV["DONT_EMAIL"]
      Childcarepro::DbExport::ReceiptMailer.sendReceipts(receipts.email, facility_folder) unless ENV["DONT_EMAIL"]

      receipts= writers = nil
end