module CalendarHelper
  # Generates a calendar (as a table) for an array of objects placing each of them on the corresponding date.
  #
  # **TODO: fully document this method, the current documentation is far from done.**
  #
  # @param [Hash] options extra options
  #
  #   :row_header if true, each row will have an extra cell at the beginning, as a row header. A typical usage would be
  #   to output week numbers. When the block is called, it will get the date that would normally be passed to the
  #   first day of the week (to give you some context) and a nil list of objects (and that's how you recognize it as
  #   a header, because empty days get an empty array, not nil).
  def calendar_for(objects, *args)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    html_options = options[:html]
    builder = options[:builder] || CalendarBuilder
    calendar = options[:calendar] || Calendar
    content_tag(:table, nil, html_options) do
      yield builder.new(objects || [], self, calendar, options)
    end
  end

  class CalendarBuilder < TableHelper::TableBuilder
    def initialize(objects, template, calendar, options)
      super(objects, template, options)
      @calendar = calendar.new(options)
      @today = options[:today] || Time.now
      @row_header = options[:row_header] || false
    end

    def day(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      day_method = options.delete(:day_method) || :date
      day_method_args = options.delete(:args) || []
      id_pattern = options.delete(:id)
      tbody do
        @calendar.objects_for_days(@objects, day_method, day_method_args).to_a.sort{|a1, a2| a1.first <=> a2.first }.each do |o|
          key, array = o
          day, objects = array
          concat(tag(:tr, options, true)) if(day.wday ==  @calendar.first_weekday)
          if @row_header && day.wday ==  @calendar.first_weekday
            row_header_options = td_options(day, id_pattern)
            row_header_options[:class] ||= ""
            row_header_options[:class] << " row_header"
            concat(tag(:td, row_header_options, true))
            yield(day, nil)
            concat("</td>")
          end
          concat(tag(:td, td_options(day, id_pattern), true))
          yield(day, objects)
          concat('</td>')
          concat('</tr>') if(day.wday ==  @calendar.last_weekday)
        end
      end
    end

    private

    def objects_for_days
      @calendar.objects_for_days(@objects)
    end

    def td_options(day, id_pattern)
      options = {}
      css_classes = []
      css_classes << 'today'    if day.strftime("%Y-%m-%d") ==  @today.strftime("%Y-%m-%d")
      css_classes << 'notmonth' if day.month != @calendar.month
      css_classes << 'weekend'  if day.wday == 0 or day.wday == 6
      css_classes << 'future'   if day > @today.to_date
      options[:class] = css_classes.join(' ') unless css_classes.empty?
      options[:id]    = day.strftime(id_pattern) if id_pattern
      options
    end

  end

  class Calendar
    attr_accessor :first_weekday, :last_weekday, :month

    # :first lets you set the first day to start the calendar on (default is the first day of the given :month and :year).
    #   :first => :today will use Date.today
    # :last lets you set the last day of the calendar (default is the last day of the given :month and :year).
    #   :last => :thirty will show 30 days from :first
    #   :last => :week will show one week
    def initialize(options={})
      @year               = options[:year] || Time.now.year
      @month              = options[:month] || Time.now.month
      @first_day_of_week  = options[:first_day_of_week] || 0
      @first_weekday      = first_day_of_week(@first_day_of_week)
      @last_weekday       = last_day_of_week(@first_day_of_week)

      @first = options[:first]==:today ? Date.today : options[:first] || Date.civil(@year, @month, 1)

      if options[:last] == :thirty_days || options[:last] == :thirty
        @last = @first + 30
      elsif options[:last] == :one_week || options[:last] == :week
        @last = @first
      else
        @last = options[:last] || Date.civil(@year, @month, -1)
      end

    end

    def each_day
      first_day.upto(last_day) do |day|
        yield(day)
      end
    end

    def last_day
      last = @last
      while(last.wday % 7 != @last_weekday % 7)
        last = last.next
      end
      last
    end

    def first_day
      first = @first - 6
      while(first.wday % 7 != (@first_weekday) % 7)
        first = first.next
      end
      first
    end

    def objects_for_days(objects, day_method, day_method_args)
      unless @objects_for_days
        @objects_for_days = {}
        days.each{|day| @objects_for_days[day.strftime("%Y-%m-%d")] = [day, []]}
        objects.each do |o|
          date = o.send(day_method.to_sym, *day_method_args)
          if date.is_a? Range
            date.each do |d|
              date_key = d.strftime("%Y-%m-%d")
              if @objects_for_days[date_key]
                @objects_for_days[date_key][1] << o
              end
            end
          else
            date_key = date.strftime("%Y-%m-%d")
            if @objects_for_days[date_key]
              @objects_for_days[date_key][1] << o
            end
          end
        end
      end
      @objects_for_days
    end

    def days
      unless @days
        @days = []
        each_day{|day| @days << day}
      end
      @days
    end

    def mjdays
      unless @mjdays
        @mdays = []
        each_day{|day| @days << day}
      end
      @days
    end

    def first_day_of_week(day)
      day
    end

    def last_day_of_week(day)
      if day > 0
        day - 1
      else
        6
      end
    end
  end
end
