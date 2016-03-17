require '../lib/solareventcalculator'

require 'date'
date = Date.parse('2008-11-01') #01 November 2008
lat  = 39.9537
lng  = -75.7850

calc = SolarEventCalculator.new(date, lat, lng)
calc.compute_sun_true_longitude(298.7585)
calc.compute_right_ascension(219.6960)
calc.put_ra_in_correct_quadrant(219.6960)
calc.compute_sine_sun_declination(219.6960)
p calc.compute_cosine_sun_declination(-0.2541)
p calc.compute_cosine_sun_declination(BigDecimal.new("-0.2541"))
calc.compute_cosine_sun_local_hour(219.6960, 96)
calc.compute_local_hour_angle(0.0791, true)
calc.compute_local_mean_time(219.6960, -5.0523, 306.4605, 18.3025)

calc.compute_utc_astronomical_sunrise
calc.compute_utc_nautical_sunrise
calc.compute_utc_civil_sunrise
calc.compute_utc_official_sunrise

calc.compute_astronomical_sunrise('America/New_York')
calc.compute_nautical_sunrise('America/New_York')
calc.compute_civil_sunrise('America/New_York')
calc.compute_official_sunrise('America/New_York')