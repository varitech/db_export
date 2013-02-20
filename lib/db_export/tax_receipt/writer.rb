module Childcarepro::DbExport
  module TaxReceipt
      module Writer
        def initialize(output_folder)
           @output_folder= output_folder
           Dir.mkdir(@output_folder) unless File.exists?(@output_folder)
    
        end
        
      	def write (data)
      	  facility_folder = File.join(@output_folder, "#{data.year}-#{data.facility_name}")
      	  Dir.mkdir(facility_folder) unless File.exists?(facility_folder)
      	  
    		  data.tax_receipts.each_with_index do |receipt,idx|
    		    output_name = File.join(facility_folder, "#{idx}_#{receipt.contact_name}.csv")
            write_receipt(data.facility_name, data.year, receipt, idx, output_name)
  		    end
      	end
      end
  end
end


