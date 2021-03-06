require 'birbl/date_parser'

[
"20140101T153000Z/20140101T163000Z",
"20140101T153000ZP1Y3M2DT2H30M,20140104T153000ZP0Y0M0DT2H30M",
"20140101T153000ZP0Y0M0DT2H30MRRULE:FREQ=WEEKLY;BYDAY=TU,TH;UNTIL=20140115T163000Z"
].each do |datestring|
  puts datestring
  dp = Birbl::DateParser.new(datestring)
  puts dp.dates.to_yaml
end

