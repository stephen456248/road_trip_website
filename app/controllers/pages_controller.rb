class PagesController < ApplicationController
  def home
    session[:dummy_data] = 3
  end

  def weather
  end

  def weather_input
    session[:forecasts] ||= []
    geo = geocoding_api_query!
    weather = weather_api_query!
    session[:debug_weather] = weather.dup.to_json
    forecast = Forecast.new(weather, params["city"])
    session[:forecasts] << forecast
    session[:forecasts] = session[:forecasts].uniq.last 4
    redirect_to "/output"
  end

  def roads
  end

  def roads_input
      session[:roads] ||= []
      url_base = "http://www.dot.ca.gov/hq/roadinfo/"
      road = HTTParty.get(url_base + params[:road])
      session[:roads] << road.parsed_response.gsub(/\r\n/, "<br>")
      session[:roads] = session[:roads].uniq.last 4
      redirect_to "/output"
  end

  def cams
    redirect_to 'http://quickmap.dot.ca.gov/'
  end

  def output
    session[:forecasts] ||= []
    session[:roads] ||= []
    @forecasts = session[:forecasts]
    @roads = session[:roads]
  end

  private

  def geocoding_api_query!
    geocoding_api_key = ENV["GEOCODING_API_KEY"]
    google_url = "https://maps.googleapis.com/maps/api/geocode/json?"
    google_params = "address=" + params["city"].gsub(" ", "%20") + "&" +
                    "key=" + geocoding_api_key
    @geo = HTTParty.get(google_url + google_params, verify: false)
    @geo.parsed_response
  end

  def weather_api_query!
    @data = HTTParty.get(weather_url + weather_params)
    @data.parsed_response
  end

  def lat
    @geo["results"].first["geometry"]["location"]["lat"]
  end

  def lon
    @geo["results"].first["geometry"]["location"]["lng"]
  end

  def endtime
    (Time.now + 8.day).strftime("%Y-%m-%d")
  end

  def weather_url
    "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?"
  end

  def weather_params
    "lat=#{lat}" + "&" +
    "lon=#{lon}" + "&" +
    "end=#{endtime}T00:00:00" + "&" +
    "product=glance"
  end


end
