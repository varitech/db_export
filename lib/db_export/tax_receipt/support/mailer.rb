require 'zip/zip'

module Childcarepro::DbExport
      module ReceiptMailer
        Mail.defaults do
          delivery_method :smtp, { 
                :address              => "smtp.gmail.com",
                :port                 => 587,
                :user_name            => ENV['CCP_EMAIL_USER'],
                :password             => ENV['CCP_EMAIL_PWD'],
                :authentication       => :plain,
                :enable_starttls_auto => true  
              }
        end
        
        def self.sendReceipts(to_address, file_path)
          zipfile_name = File.join(file_path, "archieve.zip")
          File.delete(zipfile_name) if File.exist?(zipfile_name)
          Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|

              Dir.glob(file_path+'/*').each do |filename| 
                 zipfile.add(File.basename(filename),filename) unless filename=~/archieve/
              end
          end
            mail = Mail.new do
              from    'support@childcarepro.ca'
              to      to_address
              cc      'support@childcarepro.ca'
              subject 'Tax receipts: fees $ payments break down'
              body    "Need text here!"
            end
            mail.add_file zipfile_name
            mail.deliver!
        end
      end
end