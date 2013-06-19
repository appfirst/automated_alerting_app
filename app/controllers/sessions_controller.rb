class SessionsController < ApplicationController
  require "base64"
  require "json"
  require "httparty"
  require 'ruby-standard-deviation'
  require 'statistics2'

  def call
    #note: problem was because I was not using ssl
    pass = Base64.encode64("#{Rails.application.config.user_name}:#{Rails.application.config.api_key}")
    auth = {:username => Rails.application.config.user_name, :password => pass}

    response = HTTParty.get(params[:url], 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    render :json => response #note: render only works in conjunction with an ajax request
  end

  def call2(url)
    #note: problem was because I was not using ssl
    pass = Base64.encode64("#{Rails.application.config.user_name}:#{Rails.application.config.api_key}")
    auth = {:username => Rails.application.config.user_name, :password => pass}

    response = HTTParty.get(url, 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    return response
  end

  # GET /sessions/1
  # GET /sessions/1.json
  def show
    @session = Session.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @session }
    end
  end

  # GET /sessions/new
  # GET /sessions/new.json
  def new
    @session = Session.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @session }
    end
  end

  def init
    data = call2("https://wwws.appfirst.com/api/servers/245111/data/?num=180")
    @timeseries = create_timeseries(data, "cpu")
    average(@timeseries)
    hour_test(@timeseries)
    grubbs_test(@timeseries)
  end

  def three_minute_average(timeseries)
    len = timeseries.length
    return (timeseries[len-1] + timeseries[len-2] + timeseries[len-3]) / 3
  end

  def average(timeseries)
    return timeseries.instance_eval { reduce(:+) / size.to_f }
  end

  def create_timeseries(data, tag)
    json = JSON.parse(data.to_s().gsub('=>', ':'))

    $i = 0;

    @timeseries = Array.new 

    while json[$i] != nil do
      @timeseries[$i] = json[$i][tag]
      $i += 1
    end

    return @timeseries
  end

  def hour_test(timeseries)

    len = timeseries.length
    timeseries[len-1] = 0.5

    puts timeseries

    avg = average(timeseries)
    std = timeseries.stdev
    tail = three_minute_average(timeseries)

    puts (tail-avg).abs > (3 * std)
  end


  #Grubbs test not currently working
  def grubbs_test(timeseries)

    len = timeseries.length
    timeseries[len-1] = 0.5

    deviation = timeseries.stdev
    avg = average(timeseries)
    tail = three_minute_average(timeseries)
    grubbs_stat = (tail - avg)/deviation

    len = timeseries.length

    #decided on 0.05 for threshold arbitrarily
    threshold = Statistics2.t__X_(0.05 / (2 * len), len - 2)**2
    threshold_squared = threshold*threshold

    score = ((len - 1)/Math.sqrt(len)) * Math.sqrt(threshold_squared/(len-2+threshold_squared))

    puts grubbs_stat > score
  end
end