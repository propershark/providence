class TimetableStrategy < Providence::Strategy
  def visits_between station_id, start_time, end_time, limit
    @transport.call 'timetable.visits_between', args: [
      station_id,
      start_time.strftime(date_format),
      end_time.strftime(date_format),
      limit
    ] do |result|
      yield result.args.first.map { |a| a << {realtime: false} }
    end
  end
end
