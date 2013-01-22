require 'spec_helper'
require 'logstash-cli/command/grep'

describe Grep do
  it "determines index range needed for a given date range" do
    from = 1358832972
    to = 1359005772
    Grep.indexes_from_interval(Time.at(from), Time.at(to)).should == ["2013.01.21", "2013.01.22", "2013.01.23"]
  end

  it "calculates time range required to search last X minutes" do
    # The to_i removes fractions seconds.  Unsure on the best way to test this.
    diff = 10*60
    Grep.parse_time_range("10m").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10mins").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 min").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 minute").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 minutes").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
  end

  it "calculates time range required to search last X hours" do
    diff = 10*60*60
    Grep.parse_time_range("10h").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10hr").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10hrs").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 hour").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 hours").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
  end

  it "calculates time range required to search last X days" do
    diff = 10*86400
    Grep.parse_time_range("10d").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10days").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 day").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
  end

  it "calculates time range required to search last X weeks" do
    diff = 10*7*86400
    Grep.parse_time_range("10w").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10wk").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 wks").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 week").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 weeks").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
  end

  it "calculates time range required to search last X years" do
    diff = 10*365*86400
    Grep.parse_time_range("10y").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 yr").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 yrs").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 year").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
    Grep.parse_time_range("10 years").map{|t| t.to_i}.should == [Time.now - diff, Time.now].map{|t| t.to_i}
  end

  it "raises an ArgumentError if it can't cacluate the time range" do
    lambda {Grep.parse_time_range("two-weeks")}.should raise_error ArgumentError
    lambda {Grep.parse_time_range("10parsecs")}.should raise_error ArgumentError
  end

end
