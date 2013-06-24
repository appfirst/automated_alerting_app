class AlertsController < ApplicationController
  require "base64"
  require "json"
  require "httparty"
  require 'ruby-standard-deviation'
  require 'statistics2'
  respond_to :html, :xml, :js

  def index
    @alerts = Alert.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end
 
  def show
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alert }
    end
  end

  def new
    logger.debug(session[:id])
    @alert = Alert.new
    @alert.server_id = session[:id]
    @alert.save
  end

  def create
    @alert = Alert.new(params[:alert])

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @alert, notice: 'Alert was successfully created.' }
        format.json { render json: @alert, status: :created, location: @alert }
      else
        format.html { render action: "new" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @alert = Alert.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(params[:alert])
        format.html { redirect_to @alert, notice: 'Alert was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.json
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to alerts_url }
      format.json { head :no_content }
    end
  end

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

  def init()
    data = call2("https://wwws.appfirst.com/api/servers/#{params[:id]}/data/?num=180")
    @timeseries = create_timeseries(data, "cpu")
    #average(@timeseries)
    #grubbs test not currently working
    #grubbs_test(@timeseries)
    if hour_test(@timeseries) == true
      session[:id] = params[:id];
      new
    elsif 
      session[:id] = params[:id];
      new
    end
    render :json => hour_test(@timeseries)
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

    # uncomment to create an anomaly for testing purposes
    # be sure to modify value so that it is anomalous
    len = timeseries.length

    avg = average(timeseries)
    std = timeseries.stdev
    tail = three_minute_average(timeseries)

    puts (tail-avg).abs > (3*std)
    return (tail-avg).abs > (3 * std)
  end


  #Grubbs test not currently working
  def grubbs_test(timeseries)

    len = timeseries.length

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
    return grubbs_stat > score
  end
end
