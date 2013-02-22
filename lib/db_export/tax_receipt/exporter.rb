require 'highline'

module Childcarepro::DbExport
  module TaxReceipt
      class Exporter
        attr_reader :facility
        
        def initialize(year, console, options)
          @console = console
          @year = year
          @facility =choose_faclility(options)
          
        end

        def export
          @console.say @console.color("Exporting tax receipts for '#{@facility.FACILITYNAME}', #{@year}" , :green) if ENV["DEBUG"]
          OpenStruct.new(
            :facility_name => @facility.FACILITYNAME,
            :email=>@facility.CONTACTEMAIL,
            :year => @year,
            :tax_receipts => @facility
                      .contacts
                      .sort_by { |c| [c.FIRSTNAME||'',c.LASTNAME||''] }
                      .map     { |contact| generate_tax_receipt(contact) }
                      .reject  { |receipt| receipt.invoice_charges.empty? }
                      .reject  { |receipt| receipt.outstanding_amount==0 && receipt.payments.sum(&:AMOUNT) ==0 && receipt.invoice_charges.detail.map(&:children_charges).flatten.empty?})
        end
        
        def self.each_exporter(year,console)
          idx =0
          Facility.where("status='Active'").each do |f|
             exporter = Exporter.new(year,console, { facility_id: f.id })
             yield exporter, idx+=1
             exporter = nil
          end
        end
        
        private 
    
        def generate_tax_receipt(contact)
           @console.say contact.full_name if ENV["DEBUG"]
           OpenStruct.new(
            :contact_name=> contact.full_name,
            :outstanding_amount=>  ContactHelper.outstanding_amount(contact,@year),
            :invoice_charges=> ContactHelper.invoice_charges(contact, @year) ,
            :payments=> ContactHelper.receivables_from_year(contact, @year),
            :closing_balance=> ContactHelper.outstanding_amount(contact,@year+1).round(2))
        end
    
        def choose_faclility(options)
            if options[:facility_name] then
                facility_name = options[:facility_name]
                facilities = Facility.where("FACILITYNAME like ?", "%#{facility_name}%")
                raise ArgumentError, "Facility #{facility_name} not found" if facilities.empty?

                if facilities.size > 1
                  @console.say @console.color("There are #{facilities.size} facilities that name cotain '#{facility_name}', please choose one from the list" , :red)
                  choice = @console.choose(*facilities.map(&:FACILITYNAME).sort)
                end 

                facilities.find{|f| f.FACILITYNAME==choice}|| facilities.first
            elsif options[:facility_id] then
                Facility.find(options[:facility_id]);
            else
               raise ArgumentError, "need either a facility id or a facility"
            end
        end
        
      end
    end
end