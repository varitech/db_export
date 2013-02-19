module SeedDataHelper
  
  def setup_billing_periods
    setup_bp_mb
    setup_bp_monthly
  end
  
  def setup_reports
    Report::REPORTS.each do |report|
      FactoryGirl.create(:report, report)
    end    
  end
  
  def setup_bp_mb
    d = Date.parse('2011-11-27')
    while d <= Date.today + 4.weeks
      FactoryGirl.create(:billing_period, BILLINGPERIOD: d)
      d += 4.weeks
    end
  end
  
  def setup_bp_monthly
    (-3..6).each do |i|
      d = Date.today >> i 
      FactoryGirl.create(:monthly_billing_period, 
                          BILLINGPERIOD: d.strftime('%Y-%m-01'), 
                          BILLINGPERIODNUMBER: d.strftime('%b %y').upcase)
    end
  end
end
