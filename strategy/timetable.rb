class TimetableStrategy < Providence::Strategy
  def visits_between station_id, start_time, end_time, limit
    result = EM::DefaultDeferrable.new
    EM::Deferrable.future(
      @transport.call('timetable.visits_between', args: [
        station_id,
        start_time.strftime(date_format),
        end_time.strftime(date_format),
        limit
      ]),
      proc do |response|
        result.succeed response.args.first.map { |a| a << {realtime: false} }
      end,
      result.method(:fail)
    )
    result
  end
end
