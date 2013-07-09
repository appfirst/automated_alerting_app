class ApplicationController < ActionController::Base
  protect_from_forgery

  def populate_database
    auth = {:username => Rails.application.config.user_name, :password => Rails.application.config.api_key}

    response = HTTParty.get("https://wwws.appfirst.com/api/servers", 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    $i = 0;
    while response[$i] != nil and Server.where(nickname: response[$i]["nickname"]).exists? == false do
      s = Server.new
      s.nickname = response[$i]["nickname"]
      s.hostname = response[$i]["hostname"]
      s.os = response[$i]["os"]
      s.server_id = response[$i]["id"]
      s.current_version = response[$i]["current_version"]
      s.save

      $i += 1
    end


    response = HTTParty.get("https://wwws.appfirst.com/api/servers/999/data/", 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    $i=0
    data = response[0].to_s.split(",")

    while data[$i] != nil do
      if Attribute.where(name: data[$i].scan(/"([^"]*)"/).to_s.gsub("[","").gsub("]","").gsub("\"", "")).exists? == false 
        a = Attribute.new
        a.name = data[$i].scan(/"([^"]*)"/).to_s.gsub("[","").gsub("]","").gsub("\"", "")
        a.save
      end
      $i+=1
    end

    redirect_to :root
  end

  def call
    #note: problem was because I was not using ssl
    auth = {:username => Rails.application.config.user_name, :password => Rails.application.config.api_key}

    response = HTTParty.get(params[:url], 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    render :json => response #note: render only works in conjunction with an ajax request
  end

  def call2(url)
    #note: problem was because I was not using ssl
    auth = {:username => Rails.application.config.user_name, :password => Rails.application.config.api_key}

    response = HTTParty.get(url, 
      :basic_auth => auth,
      :headers => {'Content-Type' => 'application/json'})

    return response
  end

  def init()
    data = call2("https://wwws.appfirst.com/api/servers/#{params[:id]}/data/?num=180")
    @timeseries = create_timeseries(data, params[:attr])

    if hour_test(@timeseries) == true
      session[:server_id] = params[:id]
      @alert = Alert.new
      @alert.server_id = params[:id]
      @alert.attr = params[:attr]
      @alert.server_name = Server.find_by(server_id: params[:id]).nickname
      @alert.time_stamp = data[0]["time"]
      @alert.save
    end
    render :partial => "alerts/table"
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
      if json[$i][tag] != nil 
        @timeseries[$i] = json[$i][tag]
        $i += 1
      end
    end
    return @timeseries
  end

  def hour_test(timeseries)

    if Rails.application.config.error == "true"
      len = timeseries.length
      timeseries[len-1] = 109
    end
    avg = average(timeseries)
    logger.debug("this is the average")
    logger.debug(avg)

    std = timeseries.stdev
    logger.debug("this is the standard")
    logger.debug(std)

    tail = three_minute_average(@timeseries)
    logger.debug("this is the tail average")
    logger.debug(tail)

    logger.debug( (tail-avg).abs > (3*std))
    return (tail-avg).abs > (3 * std)
  end

  def toggle_error
    if Rails.application.config.error == "true"
      Rails.application.config.error = "false"
    elsif Rails.application.config.error == "false"
      Rails.application.config.error = "true"
    end
    logger.debug("toby" + Rails.application.config.error)
    redirect_to :root
  end

  #Grubbs test not currently working
  def grubbs_test(timeseries)

    logger.debug(timeseries)

    len = timeseries.length

    if Rails.application.config.error == "true"
      timeseries[len-1] = 20
    end

    deviation = timeseries.stdev
    avg = average(timeseries)
    tail = three_minute_average(timeseries)
    grubbs_stat = (tail - avg)/deviation

    #decided on 0.05 for threshold arbitrarily
    threshold = Statistics2.t__X_(0.05 / (2 * len), len - 2)**2
    threshold_squared = threshold*threshold

    score = ((len - 1)/Math.sqrt(len)) * Math.sqrt(threshold_squared/(len-2+threshold_squared))

    puts grubbs_stat > score
    return grubbs_stat > score
  end
end
