require 'bigdecimal'
require 'date'
require 'tzinfo'

class SolarEventCalculator

  @date
  @latitude
  @longitude
  @pi
  @cycle
  @to_rad
  @to_deg

  def initialize(date, latitude, longitude)
    @date = date
    @latitude = latitude
    @longitude = longitude
    @pi = Math::PI
    @cycle = @pi * 2
    @to_rad = @pi / 180.0 
    @to_deg = 180.0 / @pi
  end

  def compute_lnghour
    lngHour = @longitude / BigDecimal.new("15")
    lngHour.round(4)
  end

  def compute_longitude_hour(isSunrise)
    minuend = (isSunrise) ? BigDecimal.new("6") : BigDecimal.new("18")
    longHour = @date.yday + ((minuend - compute_lnghour) / BigDecimal.new("24"))
    longHour.round(4)
  end

  def compute_sun_mean_anomaly(longHour)
    constant = BigDecimal.new("0.9856")
    ((longHour * constant) - BigDecimal.new("3.289")).round(4)
  end

  def compute_sun_true_longitude(meanAnomaly)
    mAsRads = meanAnomaly * @to_rad
    sinM = Math.sin(mAsRads) #BigDecimal.new(Math.sin(mAsRads.to_f).to_s)
    sinTwoM = Math.sin(2 * mAsRads)#BigDecimal.new(Math.sin((2 * mAsRads).to_f).to_s)
    firstParens = sinM * 1.916 #BigDecimal.new("1.916") * sinM
    secondParens = sinTwoM * 0.020 #BigDecimal.new("0.020") * sinTwoM
    trueLong = meanAnomaly + firstParens + secondParens + 282.634#+ BigDecimal.new("282.634")
    trueLong = put_in_range(trueLong, 0, 360, 360)
    trueLong.round(4)
  end

  def compute_right_ascension(sunTrueLong)
    tanL = Math.tan(sunTrueLong * @to_rad) #BigDecimal.new(Math.tan(degrees_to_radians(sunTrueLong).to_f).to_s)
    ra = Math.atan(0.91764 * tanL) * @to_deg#radians_to_degrees(BigDecimal.new(Math.atan(BigDecimal.new("0.91764") * tanL).to_s))

    ra = put_in_range(ra, 0, 360, 360)
    ra.round(4)
  end

  def put_ra_in_correct_quadrant(sunTrueLong)
    lQuadrant = 90.0 * (sunTrueLong / 90.0).floor #BigDecimal.new("90") * (sunTrueLong / BigDecimal.new("90")).floor
    raQuadrant = 90.0 * (compute_right_ascension(sunTrueLong) / 90.0).floor# BigDecimal.new("90") * (compute_right_ascension(sunTrueLong) / BigDecimal.new("90")).floor

    ra = compute_right_ascension(sunTrueLong) + (lQuadrant - raQuadrant)
    ra = ra / 15.0 #BigDecimal.new("15")
    ra.round(4)
  end

  def compute_sine_sun_declination(sunTrueLong)
    sinL = Math.sin(sunTrueLong * @to_rad) #BigDecimal.new(Math.sin(degrees_to_radians(sunTrueLong).to_f).to_s)
    sinDec = sinL * 0.39782 #BigDecimal.new("0.39782")
    sinDec.round(4)
  end

  def compute_cosine_sun_declination(sinSunDeclination)
    cosDec = Math.cos(Math.asin(sinSunDeclination)) #BigDecimal.new(Math.cos(Math.asin(sinSunDeclination)).to_s)
    cosDec.round(4)
  end

  def compute_cosine_sun_local_hour(sunTrueLong, zenith)
    cosZenith = Math.cos(zenith * @to_rad) #BigDecimal.new(Math.cos(degrees_to_radians(BigDecimal.new(zenith.to_s))).to_s)
    sinLatitude = Math.sin(@latitude * @to_rad) #BigDecimal.new(Math.sin(degrees_to_radians(@latitude)).to_s)
    cosLatitude = Math.cos(@latitude * @to_rad) #BigDecimal.new(Math.cos(degrees_to_radians(@latitude)).to_s)

    sinSunDeclination = compute_sine_sun_declination(sunTrueLong)
    top = cosZenith - (sinSunDeclination * sinLatitude)
    bottom = compute_cosine_sun_declination(sinSunDeclination) * cosLatitude

    cosLocalHour = top / bottom
    cosLocalHour.round(4)
  end

  def compute_local_hour_angle(cosSunLocalHour, isSunrise)
    acosH = Math.acos(cosSunLocalHour)#BigDecimal.new(Math.acos(cosSunLocalHour).to_s)
    acosHDegrees = acosH * @to_deg
    #p isSunrise
    
    localHourAngle = (isSunrise) ? @cycle - acosH : acosH#(isSunrise) ? BigDecimal.new("360") - acosHDegrees : acosHDegrees
    localHourAngle = localHourAngle / 15.0 #BigDecimal.new("15")
    (localHourAngle * @to_deg).round(4)
  end

  def compute_local_mean_time(sunTrueLong, longHour, t,  sunLocalHour)
    h = sunLocalHour
    ra = put_ra_in_correct_quadrant(sunTrueLong)

    parens = 0.06571 * t #BigDecimal.new("0.06571") * t
    time = h + ra - parens - 6.622 #BigDecimal.new("6.622")

    utcTime = time - longHour
    utcTime = put_in_range(utcTime, 0, 24, 24)
    utcTime.round(4)
  end

  def compute_utc_solar_event(zenith, isSunrise)
    longHour = compute_lnghour
    eventLongHour = compute_longitude_hour(isSunrise)

    meanAnomaly = compute_sun_mean_anomaly(eventLongHour)
    sunTrueLong = compute_sun_true_longitude(meanAnomaly)
    cosineSunLocalHour = compute_cosine_sun_local_hour(sunTrueLong, zenith)

    if(cosineSunLocalHour > BigDecimal.new("1") || cosineSunLocalHour < BigDecimal.new("-1"))
      return nil
    end

    sunLocalHour = compute_local_hour_angle(cosineSunLocalHour, isSunrise)
    localMeanTime = compute_local_mean_time(sunTrueLong, longHour, eventLongHour, sunLocalHour)

    timeParts = localMeanTime.to_f.to_s.split('.')
    mins = BigDecimal.new("." + timeParts[1]) * BigDecimal.new("60")
    mins = mins.truncate().to_f
    # mins = pad_minutes(mins.to_i)
    hours = timeParts[0].to_f

    Time.utc(@date.year, @date.mon, @date.mday, hours, pad_minutes(mins.to_i), 0).to_datetime
    DateTime.new(@date.year, @date.mon, @date.day, hours, mins, 0)
  end

  def convert_to_datetime(time)
    DateTime.parse("#{@date.strftime}T#{time.hour}:#{time.min}:00+0000") unless time == nil
  end

  def get_utc_offset(timezone)
    tz = TZInfo::Timezone.get(timezone)
    noonUTC = Time.gm(@date.year, @date.mon, @date.mday, 12, 0)
    tz.utc_to_local(noonUTC) - noonUTC
  end

  def put_in_timezone(utcTime, timezone)
    date = utcTime.to_date    
    offset = Rational((get_utc_offset(timezone) / 60.0 / 60.0).to_i, 24)  
    time = utcTime + offset.to_f 
    # local = (utcTime.to_time.utc + offset).to_datetime
    # offset = (offset > 0) ? "+" + offset.to_s : offset.to_s

    # timeInZone = DateTime.parse("#{@date.strftime}T#{local.strftime('%H:%M:%S')}#{offset}")
    # puts "CALC:timeInZone #{timeInZone}" 
    # dts = "#{@date.strftime}T#{local.strftime('%H:%M:%S')}#{offset}"
    # DateTime.parse(dts)
    DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, offset)
  end

  def compute_utc_astronomical_sunrise
    # convert_to_datetime(compute_utc_solar_event(108, true))
    compute_utc_solar_event(108, true)
  end

  def compute_astronomical_sunrise(timezone)
    date_time = compute_utc_solar_event(108, true)
    put_in_timezone(date_time, timezone)
  end

  def compute_utc_nautical_sunrise
    # convert_to_datetime(compute_utc_solar_event(102, true))
    compute_utc_solar_event(102, true)
  end

  def compute_nautical_sunrise(timezone)
    compute_utc_solar_event(102, true)
    put_in_timezone(compute_utc_solar_event(102, true), timezone)
  end  

  def compute_utc_civil_sunrise
    # convert_to_datetime(compute_utc_solar_event(96, true))
    compute_utc_solar_event(96, true)
  end

  def compute_civil_sunrise(timezone)
    compute_utc_solar_event(96, true)
    put_in_timezone(compute_utc_solar_event(96, true), timezone)
  end  

  def compute_utc_official_sunrise
    # convert_to_datetime(compute_utc_solar_event(90.8333, true))
    compute_utc_solar_event(90.8333, true)
  end

  def compute_official_sunrise(timezone)
    sr = compute_utc_solar_event(90.8333, true)
    put_in_timezone(sr, timezone)
  end

  def compute_utc_official_sunset
    # convert_to_datetime(compute_utc_solar_event(90.8333, false))
    compute_utc_solar_event(90.8333, false)
  end

  def compute_official_sunset(timezone)
    compute_utc_solar_event(90.8333, false)
    put_in_timezone(compute_utc_solar_event(90.8333, false), timezone)
  end  

  def compute_utc_civil_sunset
    #convert_to_datetime(compute_utc_solar_event(96, false))
    compute_utc_solar_event(96, false)
  end

  def compute_civil_sunset(timezone)
    compute_utc_solar_event(96, false)
    put_in_timezone(compute_utc_solar_event(96, false), timezone)
  end  

  def compute_utc_nautical_sunset
    # convert_to_datetime(compute_utc_solar_event(102, false))
    compute_utc_solar_event(102, false)
  end

  def compute_nautical_sunset(timezone)
    compute_utc_solar_event(102, false)
    put_in_timezone(compute_utc_solar_event(102, false), timezone)
  end  

  def compute_utc_astronomical_sunset
    # convert_to_datetime(compute_utc_solar_event(108, false))
    compute_utc_solar_event(108, false)
  end  

  def compute_astronomical_sunset(timezone)
    compute_utc_solar_event(108, false)
    put_in_timezone(compute_utc_solar_event(108, false), timezone)
  end   

  def pad_minutes(minutes)
    if(minutes < 10)
      "0" + minutes.to_s
    else
      minutes
    end
  end

  def put_in_range(number, lower, upper, adjuster)
    if number > upper then
      number -= adjuster
    elsif number < lower then
      number += adjuster
    else
      number
    end
  end

  def degrees_to_radians(degrees)
    # pi = BigDecimal(Math::PI.to_s)
    # radian = pi / BigDecimal.new("180")
    # degrees * radian
    degrees * @to_rad
  end

  def radians_to_degrees(radians)
    #pi = BigDecimal(Math::PI.to_s)
    #degree = BigDecimal.new("180") / pi
    #radians * degree
    radians * @to_deg
  end
end
