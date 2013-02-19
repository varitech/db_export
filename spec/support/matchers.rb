RSpec::Matchers.define :be_a_fee_break_down_like do |expected|
  match do |actual|
    (actual[:childname] == expected[:childname]) && (actual[:total]==expected[:total]) && (actual[:fees].should =~ expected[:fees]) 
    
  end

  failure_message_for_should do |actual|
    "expected that #{expected}, but get #{actual}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be #{expected}"
  end

  description do
    "be a list of fee break down of #{expected}"
  end
end

RSpec::Matchers.define :contain_a_fee_break_down_like do |expected|
  match do |actual|
    actual.any? do |line|
      (line[:childname] == expected[:childname]) && (line[:total]==expected[:total]) && (line[:fees] =~ expected[:fees]) 
    end
    
  end

  failure_message_for_should do |actual|
    "expected that #{expected}, but get #{actual}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be #{expected}"
  end

  description do
    "be a list of fee break down of #{expected}"
  end
end
