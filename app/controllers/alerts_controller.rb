class AlertsController < ApplicationController
  require "base64"
  require "json"
  require "httparty"
  require 'ruby-standard-deviation'
  require 'statistics2'

  layout nil
  layout 'application', :except => :show

  def index
    @alerts = Alert.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end
 
  def show
    @alert = Alert.find(params[:id])

    # respond_to do |format|
    #   format.html { render :layout => false, show => true } # your-action.html.erb
    # end

    render "show", :layout => false

  end

  def new
    logger.debug(session[:server_id])
    @alert = Alert.new
    @alert.server_id = session[:server_id]
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
end
