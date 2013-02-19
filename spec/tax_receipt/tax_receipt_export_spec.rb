require 'spec_helper'

module Childcarepro::DbExport::TaxReceipt
  describe "Exporter" do

    let(:year) {2012}
    let(:facility) { FactoryGirl.create(:facility,:BILLINGPERIODTYPE=> 2) }

    # let(:valid_type) {[1, 75]}
    # let(:invalid_type) {[10, 20, 25, 30, 35, 50, 555, 777, 888, 999]}
    # let(:billingperiod_types) {[1,2,3,5]}
    # let(:target_billing_periods) { BillingPeriod.all.select {|b| b.starts.year == target_year && b.TYPE==billingperiod_types.sample}}
    # let(:other_year_billing_periods) { BillingPeriod.all.select {|b| b.starts.year != target_year}}
    # let(:child) { current_facility.children.first }
    # let(:billing_period_id) { target_billing_periods.sample.id}
    # let(:other_year_billing_period_id) { other_year_billing_periods.sample.id}

    # subject { Exporter.new(facilities.sample, target_year, console) }
    
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
    
    
      # context "targeted year" do
      #        context "when a default contact makes payments" do
      #          let!(:charges) { FactoryGirl.create_list(:charge, rand(1..5), :child=>child, :contact=>child.default_contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>billing_period_id) }
      #        
      #          it " has fee break down for the child" do
      #            subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, charges)
      #          end
      #        end
      # 
      #        context "when multiple contacts make payments" do
      #          let!(:new_contact) { FactoryGirl.create(:child_contact, :children=>[child],:facility => current_facility, :USERID => current_facility.creator.UUID)}
      #          let!(:charges) {[]}
      #      
      #          before do
      #            #FactoryGirl.create(:contact_child_rel, CHILDID: child.UUID, CHILDCONTACTID: new_contact.UUID)
      #            child.reload
      #            child.contacts.each do |contact|
      #                charges << FactoryGirl.create_list(:charge, 2, :child=>child, :contact=>contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>billing_period_id)
      #            end
      #            charges.flatten!
      #          end
      # 
      #          it "has fee break down for the child", :focus=>true do
      #            subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, charges)
      #          end
      #        end
      #      end
      #  
      #      context "other years" do
      #           context "when a default contact makes payments" do
      #                let!(:charges) { FactoryGirl.create_list(:charge, rand(1..5), :child=>child, :contact=>child.default_contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>other_year_billing_period_id) }
      #            
      #                it "not show fee break down for the child" do
      #                    subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, [])
      #                end
      #          end
      #      end
      # 
      #      context "when a child belongs to a different facility" do
      #         let!(:new_facility) { FactoryGirl.create(:facility)}
      #         let!(:new_child) {new_facility.children.sample}
      #         let!(:charge) {FactoryGirl.create(:charge, :child=>new_child, :contact=>new_child.default_contact, :CHARGEDESCRIPTION=>new_child.full_name, :BILLINGPERIODID=>billing_period_id)}
      #    
      #         it "has empty fee break down for the child" do
      #           subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, [])
      #         end
      #      end
      # 
      #      context "when payments are not of 'Cost of care' or 'Adjustment Related' types" do
      #        let!(:charge) {FactoryGirl.create(:charge, :child=>child, :TYPE => invalid_type.sample, :contact=>child.default_contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>billing_period_id)}
      #          it "has empty fee break down for the child" do
      #           subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, []) 
      #          end
      #      end
      # 
      #      context "when payments are of 'Cost of care' or 'Adjustment Related' types" do
      #        let!(:charge) {FactoryGirl.create(:charge, :child=>child, :TYPE => valid_type.sample, :contact=>child.default_contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>billing_period_id)}
      #         it "has fee break down for the child" do 
      #          subject.generate_tax_receipt(child).should_not be_a_fee_break_down_like expected(child, [])
      #         end
      #      end
      # 
      #      context "when payments are a mix of 'Cost of care' or 'Adjustment Related' and illegal types" do
      #        let(:types) {[1, 20, 75, 999]}
      #        let!(:charges) { types.map { |type| FactoryGirl.create(:charge, :child=>child, :TYPE => type, :contact=>child.default_contact, :CHARGEDESCRIPTION=>child.full_name, :BILLINGPERIODID=>billing_period_id)} }
      #        let(:target_charges)  {charges.select {|charge| valid_type.include?(charge.TYPE)}}
      #        it "has fee break down for the child" do
      #          subject.generate_tax_receipt(child).should be_a_fee_break_down_like expected(child, target_charges)
      #        end
      #      end
      #    end
      # 
      #    describe '#export' do
      #      before do
      #        subject.class.class_eval do 
      #          define_method :child_fees do |child|
      #            child
      #          end
      #        end
      #      end
      # 
      #      it "generates child fee break down list for every child" do
      #       # subject.export.should =~ current_facility.children
      #      end
      #    end
     


  end
end