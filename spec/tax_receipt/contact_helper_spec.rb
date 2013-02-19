require 'spec_helper'

module TaxReceiptExportSpec
      include SeedDataHelper
      describe Childcarepro::DbExport::TaxReceipt::ContactHelper do

        let(:target_year)      { 2013 }
        let(:current_facility) { FactoryGirl.create(:facility, :BILLINGPERIODTYPE => 2) }
        let(:child)            { current_facility.children.first }
        let(:billing_period)   { BillingPeriod.select {|b| b.BILLINGPERIOD.year < target_year }.sample }

        describe "#outstanding_amount" do
        	context "When the invoice is for a single child" do
        	  before do
        		  FactoryGirl.create_list(:invoice_with_charges_to_child, 5, 
                                      contact: child.default_contact,
                                      charge_child: child, 
                                      charge_contact: child.default_contact, 
                                      charge_period: billing_period,
                                      charge: 10,
                                      receivable_amount: 15)
                              
      	    end

        		subject { ContactHelper.outstanding_amount(child.default_contact, target_year).to_f }
   
        		it { should == -125 }  
        	end

        	context "When the invoice is for multiple children" do
        	  before do
        	    contact = child.default_contact
        	    another_child =FactoryGirl.create(:child, :contacts=>[child.default_contact])
        	    FactoryGirl.create_list(:invoice_with_charges_to_child, 5, 
                                      contact: child.default_contact,
                                      charge_child: child, 
                                      charge_contact: child.default_contact, 
                                      charge_period: billing_period,
                                      charge: 10,
                                      receivable_amount: 15)
                              
        		  FactoryGirl.create_list(:invoice_with_charges_to_child, 5, 
                                      contact: contact,
                                      charge_child: another_child, 
                                      charge_contact: contact, 
                                      charge_period: billing_period,
                                      charge: 20,
                                      receivable_amount: 30)
                              
      	    end

        		subject { ContactHelper.outstanding_amount(child.default_contact, target_year).to_f }
   
        		it { should == -375 }
        	end
        end
      end
  end
