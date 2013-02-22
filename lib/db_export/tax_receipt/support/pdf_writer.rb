require "crafty"
require 'pdfkit'
require_relative 'writer'

module Childcarepro::DbExport
  module TaxReceipt
      class PdfWriter 
        include Writer
        include Crafty::HTML::Basic
        
      	def write_receipt (facility_name, year,receipt, idx, output_name)
          content = html do
                        body do
                          h2 facility_name
                          h3 "#{year} fees & payments"
                          div do
                            p do
                              span  "Contact Name:"
                              em receipt.contact_name
                              
                              
                              span class: ['float-right'] do
                                  span "Opening Balance:"
                                  em "$%.2f" % receipt.outstanding_amount
                              end
                              
                            end
                          end 
                          
                          div do
                            charges_table(receipt.invoice_charges)
                          end
                          
                          div do
                            receivables_table(receipt)
                          end
                          p class: ['float-right'] do
                              span "Closing Balance:"
                              em  " $%.2f" % receipt.closing_balance
                          end
                          
                          p class: ['small'] do 
                            span "(Generated at #{Time.now.strftime('%e %b %Y %H:%m:%S%p')})"
                          end
                        end
                    end
       
          kit = PDFKit.new content
          kit.stylesheets << './lib/db_export/tax_receipt/support/report.css'
          f = kit.to_file("#{output_name}.pdf")
          puts "Created file #{output_name}.pdf" if ENV["DEBUG"]
          f.close
      	end

        def charges_table(invoice_charges)
          table do
                tr do
                    ["Invocie #","Date", "Amount"].each { |h| th h }
                    invoice_charges.detail.first.children_charges.map(&:child_name).each { |h| th h }  unless invoice_charges.detail.empty? 
                    th "Misc."
                end
                
                invoice_charges.detail.map do |invoice_charge| 
                      tr do
                          td invoice_charge.invoice_number
                          td invoice_charge.invoice_date.strftime('%m/%d/%Y')
                          td "%.2f" % invoice_charge.invoice_amount
                          invoice_charge.children_charges.map(&:amount).each {|a| td "%.2f" % a } 
                          td " %.2f" % invoice_charge.misc_charges
                      end
                end
                footer =["Total Invoiced","", " %.2f" % invoice_charges.invoice_total]
                tr do
                     footer.each { |h| td h }
                     invoice_charges.child_total.each {|t| td " %.2f" % t}
                end
          end
        end
      	
        def receivables_table(receipt)
          table do
              tr do
                  ["Rec #","Date", "Amount", "Comment"] .each { |h| th h }
              end
             receipt.payments.map do |payment| 
                tr do
                   [payment.RECEIVABLENUMBER, payment.DATE.strftime('%m/%d/%Y'), "%.2f" % payment.AMOUNT,payment.PAYMENTDESCRIPTION]
                   .each {|d| td d }
                end
             end

             tr do
                  ["Total Receipt", "", "%.2f" % receipt.payments.sum(&:AMOUNT),""].each { |h| td h }
             end
          end
        end
  
      end
  end
end


