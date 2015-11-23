class Forecast
  attr_reader :weather, :city
  def initialize(weather, city)
    @city = city
    @weather = weather
    @parameters = @weather["dwml"]["data"]["parameters"]
    @highs = Array(@parameters["temperature"][0]["value"])
    @lows = Array(@parameters["temperature"][1]["value"])
    @icons = Array(@parameters["conditions_icon"]["icon_link"])
    
  end

  def periods
    return @periods if @periods
    data = @weather["dwml"]["data"]
    layouts = data["time_layout"]
    icons_lookup_by_date = layouts.find {|layout| layout["layout_key"].match(/p3h/)}["start_valid_time"]
    layouts = layouts.select {|layout| layout["layout_key"].match(/p24h/)}
    layouts = layouts.map {|layout| {key: layout["layout_key"], periods: layout["start_valid_time"]}}
    layouts.each do |layout|
      layout[:periods].map! do |period|
        {name: period["period_name"], time: period["__content__"]}
      end
    end

    parameters = data["parameters"]
    temperature_groups = parameters["temperature"]
    temperature_groups =  temperature_groups.map {|group| {key: group["time_layout"], list: group["value"], type: group["type"]}}
    temperature_groups.each do |temperature_group|
      layout = layouts.find {|layout| layout[:key] == temperature_group[:key]}
      layout = layout[:periods].map.with_index do |period, index|
        period[:temp] = temperature_group[:list][index]
        period[:type] = temperature_group[:type].eql?("maximum") ? "high" : "low"
        period
      end
    end

    icon_urls = parameters["conditions_icon"]["icon_link"]

    layouts.each do |layout|
      layout[:periods].each do |period|
        icon_index = 0
        if icons_lookup_by_date.index(period[:time])
          icon_index = icons_lookup_by_date.index(period[:time])
        else
          lookup_date = icons_lookup_by_date.find do |date|
            DateTime.parse(date) > DateTime.parse(period[:time])
          end
          icon_index = icons_lookup_by_date.index(lookup_date)
        end

        period[:icon] = icon_urls[icon_index]
      end
    end

    @periods = []
    layouts.each do |layout|
      @periods += layout[:periods]
    end

    @periods = @periods.sort_by {|period| DateTime.parse(period[:time])}.take 8

    return @periods

  end

  def eql?(other)
    city == other.city
  end

  def hash
    city.hash
  end

  def temp_group_for_period(key)
    @parameters["temperature"].find {|t| t["time_layout"] == key}
  end
end