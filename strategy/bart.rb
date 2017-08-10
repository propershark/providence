require 'bart_api'
require 'eventmachine'

require_relative 'timetable'

class BartStrategy < TimetableStrategy
  class << self
    include Configurable
  end

  def initialize *_
    super
    @bart = Bart.new
  end

  def visits_between station, start_time, end_time, limit
    return nil if (start_time - Time.now).abs > refresh_time 

    estimates_at(station).callback do |estimates| 
      arrivals = transform(estimates).first(2)
      if arrivals.count < limit
        # If BART didn't provide enough results, ask Timetable for more.
        super(station, Time.parse(arrivals.last[0]), end_time, 
              limit - arrivals.count) do |tt_arrivals|
          yield arrivals + tt_arrivals 
        end
      else
        yield arrivals
      end
    end
  end

  private

  def estimates_at station
    EM.defer_block { @bart.estimates.get station }
  end

  def transform station
    station.etd.map do |destination|
      # Map Destination objects to timetable-formatted arrival tuples...
      destination.arrivals.map { |arrival| tuple_for destination, arrival }
      # ...merge the different destionations into one list...
    end.flatten(1).sort do |a, b|
      # ...sort by arrival time...
      a[0] <=> b[0]
      # ...and convert times to their string format.
    end.each &(method :serialize)
  end

  # Return a timetable-style (eta, etd, route, headsign) tuple given a
  # `Destination` and one of its `Arrival`s.
  def tuple_for destination, arrival
    arrival_time = Time.now + arrival.minutes.to_i * 60
    [arrival_time, 
     arrival_time, 
     route_id_for(arrival), 
     destination.name,
     {realtime: true}]
  end

  # Given an arrival, returns the known route id by comparing the hex color of
  # the arrival. Since BART doesn't provide route numbers of its `etd`
  # endpoint, we have to look for the right route ourselves.
  def route_id_for arrival
    @agency.routes.lazy.select { |r| r[:color] == arrival.hexcolor }.first[:short_name]
  end

  # Return `arrival` with its times converted into the wire string format.
  def serialize arrival
    arrival[0] = arrival[0].strftime(date_format)
    arrival[1] = arrival[1].strftime(date_format)
  end

  def deserialize arrival
    arrival[0]
  end

  def refresh_time
    Bart.configuration.refresh_time
  end
end
