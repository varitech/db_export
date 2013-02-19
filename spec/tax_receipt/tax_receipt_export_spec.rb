require 'spec_helper'

module Childcarepro::DbExport::TaxReceipt
  describe "Exporter" do

    let(:year) {2012}
    let(:facility) { FactoryGirl.create(:facility,:BILLINGPERIODTYPE=> 2) }

    describe '.initialize' do
      context "when created" do
        subject { Exporter.new(facility.FACILITYNAME, year).facility }
        its(:FACILITYNAME) { should match facility.FACILITYNAME }
      end
      
      context "when initialized with a facility name not existing" do
        it "should raise an ArgumentError exception" do
              expect { Exporter.new("invalidname", year) }.to raise_error(ArgumentError)
        end
      end
      
      context "when initialized with a searching name results more than one facility" do
        let!(:console) { mock("HighLine") }
        
        before do
          console.stub!(:color)
          console.stub!(:say)
          console.stub!(:choose)
          3.times {|i| FactoryGirl.create(:facility,:BILLINGPERIODTYPE=> 2, :FACILITYNAME=> "facility#{i}") }
        end
        
        it "prompt a list of facitlity names to choose from" do
          console.should_receive(:choose).with("facility0","facility1","facility2")
          Exporter.new("facility", year, console)
        end
      end
    end
    
    describe '.export' do
      subject { Exporter.new(facility.FACILITYNAME, year).export}
      
      its(:facility_name) { should match facility.FACILITYNAME }
      
      its(:year) { should be year}
    end
  end
end