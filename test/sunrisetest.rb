require '../lib/solareventcalculator'
gem 'minitest'
require 'minitest/autorun'

describe SolarEventCalculator, "test the math for home" do

  before do
    @date = Date.parse('2008-11-01') #01 November 2008
    @calc = SolarEventCalculator.new(@date, BigDecimal.new("39.9537"), BigDecimal.new("-75.7850"))
  end

  it "returns correct longitude hour" do
    # assert_equal(@calc.compute_lnghour, BigDecimal.new("-5.0523"))
    assert_equal(@calc.compute_lnghour, -5.0523)
  end

  it "returns correct longitude hour" do
    # assert_equal(@calc.compute_longitude_hour(true), BigDecimal.new("306.4605"))
    assert_equal(@calc.compute_longitude_hour(true), 306.4605)
  end

  it "returns correct sunrise mean anomaly" do
    # assert_equal(@calc.compute_sun_mean_anomaly(BigDecimal.new("306.4605")), BigDecimal.new("298.7585"))
    assert_equal(@calc.compute_sun_mean_anomaly(306.4605), 298.7585)
  end

  it "returns correct sunrise's sun true longitude" do
    # assert_equal(@calc.compute_sun_true_longitude(BigDecimal.new("298.7585")), BigDecimal.new("219.6960"))
    assert_equal(@calc.compute_sun_true_longitude(298.7585), 219.6960)
  end

  it "returns correct sunrise's right ascension" do
    # assert_equal(@calc.compute_right_ascension(BigDecimal.new("219.6960")), BigDecimal.new("37.2977"))
    assert_equal(@calc.compute_right_ascension(219.6960), 37.2977)
  end

  it "returns correct sunrise's right ascension quadrant" do
    # assert_equal(@calc.put_ra_in_correct_quadrant(BigDecimal.new("219.6960")), BigDecimal.new("14.4865"))
    assert_equal(@calc.put_ra_in_correct_quadrant(219.6960), 14.4865)
  end

  it "returns correct sunrise sine sun declination" do
    # assert_equal(@calc.compute_sine_sun_declination(BigDecimal.new("219.6960")), BigDecimal.new("-0.2541"))
    assert_equal(@calc.compute_sine_sun_declination(219.6960), -0.2541)
  end

  it "returns correct sunrise cosine sun declination" do
    # assert_equal(@calc.compute_cosine_sun_declination(BigDecimal.new("-0.2541")), BigDecimal.new("0.9672"))
    assert_equal(@calc.compute_cosine_sun_declination(-0.2541), 0.9672)
  end

  it "returns correct sunrise cosine sun local hour" do
    # assert_equal(@calc.compute_cosine_sun_local_hour(BigDecimal.new("219.6960"), 96), BigDecimal.new("0.0791"))
    assert_equal(@calc.compute_cosine_sun_local_hour(219.6960, 96), 0.0791)
  end

  it "returns correct sunrise local hour angle" do
    #assert_equal(@calc.compute_local_hour_angle(BigDecimal.new("0.0791"), true), BigDecimal.new("18.3025"))
    assert_equal(@calc.compute_local_hour_angle(0.0791, true), 18.3025)
  end

  it "returns correct sunrise local mean time" do
    trueLong = BigDecimal.new("219.6960")
    longHour = BigDecimal.new("-5.0523")
    localHour = BigDecimal.new("18.3025")
    t = BigDecimal.new("306.4605")
    # assert_equal(@calc.compute_local_mean_time(trueLong, longHour, t, localHour), BigDecimal.new("11.0818"))
    assert_equal(@calc.compute_local_mean_time(trueLong, longHour, t, localHour), 11.0818)
  end

  it "returns correct UTC astronomical sunrise time" do
    assert_equal(@calc.compute_utc_astronomical_sunrise, DateTime.parse("#{@date.strftime}T10:01:00-00:00"))
  end 

  it "returns correct UTC nautical sunrise time" do
    assert_equal(@calc.compute_utc_nautical_sunrise, DateTime.parse("#{@date.strftime}T10:32:00-00:00"))
  end 

  it "returns correct UTC civil sunrise time" do
    assert_equal(@calc.compute_utc_civil_sunrise, DateTime.parse("#{@date.strftime}T11:04:00-00:00"))
  end

  it "returns correct UTC official sunrise time" do
    assert_equal(@calc.compute_utc_official_sunrise, DateTime.parse("#{@date.strftime}T11:33:00-00:00"))
  end   

  it "returns correct 'America/New_York' astronomical sunrise time" do
    assert_equal(@calc.compute_astronomical_sunrise('America/New_York'), DateTime.parse("#{@date.strftime}T06:01:00-04:00"))
  end

  it "returns correct 'America/New_York' nautical sunrise time" do
    assert_equal(@calc.compute_nautical_sunrise('America/New_York'), DateTime.parse("#{@date.strftime}T06:32:00-04:00"))
  end

  it "returns correct 'America/New_York' civil sunrise time" do
    assert_equal(@calc.compute_civil_sunrise('America/New_York'), DateTime.parse("#{@date.strftime}T07:04:00-04:00"))
  end 

  it "returns correct 'America/New_York' official sunrise time" do
    assert_equal(@calc.compute_official_sunrise('America/New_York'), DateTime.parse("#{@date.strftime}T07:33:00-04:00"))
  end  
end

describe SolarEventCalculator, "test the math for areas where there could be no rise/set" do

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    assert_equal(calc.compute_utc_nautical_sunrise, nil)
  end

  it "returns correct time" do
    date = Date.parse('2008-04-25') #25 April 2008
    calc = SolarEventCalculator.new(date, BigDecimal.new("64.8378"), BigDecimal.new("-147.7164"))
    assert_equal(calc.compute_utc_nautical_sunrise, nil)
  end
end
