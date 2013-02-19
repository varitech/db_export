require 'spec_helper'

module Childcarepro::DbExport::TaxReceipt
      include SeedDataHelper
      describe ContactHelper do

        let(:target_year)      { 2013 }
        let(:current_facility) { FactoryGirl.create(:facility, :BILLINGPERIODTYPE => 2) }
        let(:child)            { current_facility.children.first }
        let(:billing_period)   { BillingPeriod.select {|b| b.BILLINGPERIOD.year < target_year }.sample }

        describe ".outstanding_amount" do
        	context "When the invoice is for a single child" do
        	  before do
        		  FactoryGirl.create_list(:invoice_with_charges_to_child, 1, 
                                      contact: child.default_contact,
                                      charge_child: child, 
                                      charge_contact: child.default_contact, 
                                      charge_period: billing_period,
                                      charge: 15,
                                      receivable_amount: 10,
                                      DATE: billing_period.starts)
                              
      	    end

        		subject { ContactHelper.outstanding_amount(child.default_contact, target_year).to_f }
   
        		it { should == 25 }  
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
                                      charge: 30,
                                      receivable_amount: 10,
                                      DATE: billing_period.starts)
                              
        		  FactoryGirl.create_list(:invoice_with_charges_to_child, 5, 
                                      contact: contact,
                                      charge_child: another_child, 
                                      charge_contact: contact, 
                                      charge_period: billing_period,
                                      charge: 0,
                                      receivable_amount: 20,
                                      DATE: billing_period.starts)
                              
      	    end

        		subject { ContactHelper.outstanding_amount(child.default_contact, target_year).to_f }
   
        		it { should == 0 }
        	end
        end
      end
  end
