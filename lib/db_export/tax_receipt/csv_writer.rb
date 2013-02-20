require 'csv'
require_relative 'writer'

module Childcarepro::DbExport
  module TaxReceipt
      class CSVwriter 
        include Writer
        
      	def write_receipt (facility_name, year,receipt, idx, output_name)
    		    CSV.open(output_name, "wb") do |csv|
    		      csv << [""]
      		    csv << [facility_name,year]
      		    csv << ["Contact Name",receipt.contact_name, "Opening Balance", receipt.outstanding_amount]
              write_invoice_charges(csv, receipt.invoice_charges.detail)
    			    csv << ["Total Invoiced","",receipt.invoice_charges.invoice_total,receipt.invoice_charges.child_total].flatten
    			    csv <<['---']
    			    csv << ["rec Number","Date", "Amount"]
    			    receipt.payments.each do |payment| 
    			      csv << [payment.RECEIVABLENUMBER, payment.DATE.strftime('%b %d,%Y'), payment.AMOUNT,payment.PAYMENTDESCRIPTION]
    			    end
    			    csv << ["Total Receipt", receipt.payments.sum(&:AMOUNT).round(2)]
    			    csv <<["Closing Balance" ,receipt.closing_balance]
    			    csv << [""]
  			    end
      	end
  	
      	def write_invoice_charges(csv, invoice_charges)
      	  csv << ["Invocie Number","Date", "Amount", invoice_charges.first.children_charges.map { |i| i.child_name }, "Misc."].flatten  unless invoice_charges.empty? 
      	  invoice_charges.each do |invoice_charge| 
            csv << [invoice_charge.invoice_number, invoice_charge.invoice_date.strftime('%b %d,%Y'),invoice_charge.invoice_amount, invoice_charge.children_charges.map(&:amount), invoice_charge.misc_charges].flatten
    	    end
      	end
  
      end
  end
end


