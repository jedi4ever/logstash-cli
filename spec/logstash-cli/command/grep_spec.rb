require_relative '../../spec_helper.rb'
require_relative '../../../lib/logstash-cli/command/grep.rb'

describe Grep do
  it "determines index range needed for a given date range" do
    Grep.indexes_from_interval(DateTime.now, DateTime.now).should == [DateTime.now.to_date.to_s.gsub('-', '.')]
  end

  it "calculates time range required to search last X minutes" do
    # The to_i removes fractions seconds.  Unsure on the best way to test this.
    diff = 10*(1/60.0*24.0)
    Grep.parse_time_range("10m").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10mins").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 min").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 minute").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 minutes").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
  end

  it "calculates time range required to search last X hours" do
    diff = 10*(1/24.0)
    Grep.parse_time_range("10h").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10hr").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10hrs").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 hour").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 hours").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
  end

  it "calculates time range required to search last X days" do
    diff = 10
    Grep.parse_time_range("10d").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10days").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 day").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
  end

  it "calculates time range required to search last X weeks" do
    diff = 10*7
    Grep.parse_time_range("10w").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10wk").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 wks").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 week").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 weeks").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
  end

  it "calculates time range required to search last X years" do
    diff = 10*365
    Grep.parse_time_range("10y").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 yr").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 yrs").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 year").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
    Grep.parse_time_range("10 years").map{|t| t.to_time.to_i}.should == [DateTime.now - diff, DateTime.now].map{|t| t.to_time.to_i}
  end

  it "raises an ArgumentError if it can't cacluate the time range" do
    lambda {Grep.parse_time_range("two-weeks")}.should raise_error ArgumentError
    lambda {Grep.parse_time_range("10parsecs")}.should raise_error ArgumentError
  end

end
