require "crafty"
require 'pdfkit'
require_relative 'writer'

module Childcarepro::DbExport
  module TaxReceipt
      class PdfWriter 
        include Writer
        include Crafty::HTML::Basic
        
      	def write_receipt (facility_name, year,receipt, idx, output_name)
          # kit = PDFKit.new("<h1>Oh Hai!</h1>")
          content = html do
                        body do
                          h2 facility_name
                          h3 "#{year} fees & payments"
                          div do
                            p do
                              span "Contact Name:"
                              span  receipt.contact_name
                              span  "Opening Balance:"
                              span  receipt.outstanding_amount.to_s
                            end
                          end 
                          
                          div do
                            charges_table(receipt.invoice_charges)
                          end
                          
                          div do
                            receivables_table(receipt)
                          end
                          
                          div do
                            p do
                              span "Closing Balance:"
                              span  receipt.closing_balance
                            end
                          end
                        end
                    end
                    
  
          kit = PDFKit.new content
          kit.to_pdf
          kit.to_file("#{output_name}.pdf")
      	end

        def charges_table(invoice_charges)
          table do
                header = ["Invocie#","Date", "Amount"]
                header << invoice_charges.detail.first.children_charges.map(&:child_name) << "Misc." unless invoice_charges.detail.empty? 
                tr do
                    header.each { |h| th h }
                end
                
                invoice_charges.detail.map do |invoice_charge| 
                      tr do
                          td invoice_charge.invoice_number
                          td invoice_charge.invoice_date.strftime('%b %d,%Y')
                          td invoice_charge.invoice_amount
                          invoice_charge.children_charges.map(&:amount).each {|a| td a } 
                          td invoice_charge.misc_charges
                      end
                end
                footer =["Total","",invoice_charges.invoice_total,invoice_charges.child_total,""].flatten
                tr do
                     footer.each { |h| td h }
                end
          end
        end
      	
        def receivables_table(receipt)
          table do
              tr do
                  ["Rec#","Date", "Amount", "Comment"] .each { |h| th h }
              end
             receipt.payments.map do |payment| 
                tr do
                   [payment.RECEIVABLENUMBER, payment.DATE.strftime('%b %d,%Y'), payment.AMOUNT,payment.PAYMENTDESCRIPTION]
                   .each {|d| td d }
                end
             end

             tr do
                  ["Total Receipt", "",receipt.payments.sum(&:AMOUNT).round(2),""].each { |h| td h }
             end
          end
        end
  
      end
  end
end


