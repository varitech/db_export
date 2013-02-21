require 'ostruct'

module Childcarepro::DbExport
  module TaxReceipt
      module ContactHelper
        def self.valid_type
        	[1,10,20,25,30,50,75]
        end
  
        def self.outstanding_amount(contact, year)
          charges = invoices_from_year(contact, year).sum(&:total)
      
          receivables = contact.invoices
            .map(&:receivables)
            .flatten
            .select { |r| r.DATE.year < year }
            .uniq
            .sum(&:AMOUNT)
      
          (charges - receivables).round(2)
        end
  
        def self.invoices_from_year(contact, year)
          contact.invoices.select {|i| i.DATE.year < year}
        end
  
        def self.invoice_charges(contact, year)
          invoice_charge_details =  contact.invoices.sort_by {|i| [i.DATE]}.select {|i| i.DATE.year == year}.map do |invoice|
                   OpenStruct.new(
                       :invoice_amount=> invoice.total,
                       :invoice_number=> invoice.INVOICENUMBER,
                       :invoice_date=>invoice.DATE,
                       :children_charges=> contact.children.map  do |child| 
                                    OpenStruct.new(:child_name=>child.full_name, 
                                                   :amount=> invoice.charges.select { |charge|  charge_to_child?(charge, child, year)}.sum(&:AMOUNT))
                                                end,
                       :misc_charges=> invoice.charges.select { |charge| misc_charge?(contact, charge, year)  }.sum(&:AMOUNT)
                    )
                                          
           end
     
           invoice_charge_subtotals = contact.children.map  do |child| 
                           contact.invoices.map(&:charges).flatten.select {|charge| charge_to_child?(charge, child, year)}.sum(&:AMOUNT) 
                     
           end
     
           OpenStruct.new(:detail=>invoice_charge_details, :invoice_total=> invoice_charge_details.sum(&:invoice_amount),:child_total=>invoice_charge_subtotals) 
     
        end
  
        def self.receivables_from_year(contact, year)

          contact.invoices
            .map(&:receivables)
            .flatten
            .select { |r| r.DATE.year ==year }
            .uniq
            .sort_by {|r| [r.DATE]}
        end
  
        def self.charge_to_child?(charge, child, year)
          (charge.CHARGEDESCRIPTION.downcase.include?(child.full_name.downcase) || charge.CHARGEDESCRIPTION.downcase.include?("#{child.LASTNAME.downcase}, #{child.FIRSTNAME.downcase}")) &&  
                          				 charge.invoice && 
                          				 charge.invoice.DATE.year == year && 
                          				 valid_type.include?(charge.TYPE)
        end
  
        def self.misc_charge?(contact, charge, year)
          contact.children.all? {|child| !charge_to_child?(charge, child, year)}
        end
      end
  end
end