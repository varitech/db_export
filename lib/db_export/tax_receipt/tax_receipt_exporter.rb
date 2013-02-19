require 'highline'

module Childcarepro::DbExport
  module TaxReceipt
      class Exporter
        attr_reader :facility
        def initialize(facility_name, year, console=HighLine.new)
          @console = console
          @year = year
          @facility =choose_faclility(facility_name)
          @console.say @console.color("Tax Receipts for '#{@facility.FACILITYNAME}', #{year}" , :green)
        end

        def export
          OpenStruct.new(
            :facility_name => @facility.FACILITYNAME,
            :year => @year,
            :tax_receipts => @facility
                      .contacts
                      .sort_by { |c| [c.FIRSTNAME,c.LASTNAME] }
                      .map     { |contact| generate_tax_receipt(contact) }
                      .reject  { |receipt| receipt.invoice_charges.empty? }
                      .reject  { |receipt| receipt.outstanding_amount==0 && receipt.payments.sum(&:AMOUNT) ==0 && receipt.invoice_charges.detail.map(&:children_charges).flatten.empty?})
        end

        private 
    
        def generate_tax_receipt(contact)
           # puts contact.full_name
           OpenStruct.new(
            :contact_name=> contact.full_name,
            :outstanding_amount=>  ContactHelper.outstanding_amount(contact,@year),
            :invoice_charges=> ContactHelper.invoice_charges(contact, @year) ,
            :payments=> ContactHelper.receivables_from_year(contact, @year),
            :closing_balance=> ContactHelper.outstanding_amount(contact,@year+1).round(2))
        end
    
        def choose_faclility(facility_name)
            facilities = Facility.where("FACILITYNAME like ?", "%#{facility_name}%")
            raise ArgumentError, "Facility #{facility_name} not found" if facilities.empty?

            if facilities.size > 1
              @console.say @console.color("There are #{facilities.size} facilities that name cotain '#{facility_name}', please choose one from the list" , :red)
              choice = @console.choose(*facilities.map(&:FACILITYNAME).sort)
            end 

            facilities.find{|f| f.FACILITYNAME==choice}|| facilities.first
        end
        
      end
    end
end