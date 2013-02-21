require 'prawn'
require_relative 'writer'

module Childcarepro::DbExport
  module TaxReceipt
      class PdfWriter 
        include Writer
        
      	def write_receipt (facility_name, year,receipt, idx, output_name)
      	  Prawn::Document.generate("#{output_name}.pdf") do
            text "#{facility_name}", :align => :center, :size => 18, :style=> :bold
            text "#{year} fees & payments", :align => :center, :size => 12
                        
            move_down 8
            y_position = cursor - 20
            text_box "Contact Name:",:size => 14, :at=> [0, y_position]
            pad_bottom(20) { text_box receipt.contact_name, :at=> [100, y_position]}
            text_box "Opening Balance", :size => 14, :at=> [250, y_position]
            pad_bottom(20) { text_box receipt.outstanding_amount.to_s, :at=> [360, y_position]}
            
            table PdfWriter.charges_table(receipt.invoice_charges)
            move_down 8
            
            table PdfWriter.receivables_table(receipt)
            
            move_down 8
            text "Closing Balance #{receipt.closing_balance}", :align => :right, :size => 16, :style=> :bold
          end
      	end

      	def self.charges_table(invoice_charges)
      	  header = ["Invocie#","Date", "Amount"]
      	  header << invoice_charges.detail.first.children_charges.map(&:child_name) << "Misc." unless invoice_charges.detail.empty? 
      	  lines =invoice_charges.detail.map do |invoice_charge| 
                   # [invoice_charge.invoice_number, invoice_charge.invoice_date.strftime('%b %d,%Y'),invoice_charge.invoice_amount,invoice_charge.misc_charges]
                   [invoice_charge.invoice_number, invoice_charge.invoice_date.strftime('%b %d,%Y'),invoice_charge.invoice_amount, invoice_charge.children_charges.map(&:amount), invoice_charge.misc_charges].flatten
          end || []
      	  footer =["Total","",invoice_charges.invoice_total,invoice_charges.child_total,""].flatten
      	  [header.flatten] + lines +[footer]
      	end
      	
      	def self.receivables_table(receipt)
      	      header= ["Rec#","Date", "Amount", "Comment"] 
              lines = receipt.payments.map do |payment| 
                         [payment.RECEIVABLENUMBER, payment.DATE.strftime('%b %d,%Y'), payment.AMOUNT,payment.PAYMENTDESCRIPTION]
                      end || []
              footer =["Total Receipt", "",receipt.payments.sum(&:AMOUNT).round(2),""]
              [header] + lines +[footer]
      	end
  
      end
  end
end


