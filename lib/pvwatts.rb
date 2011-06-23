require 'rubygems'
require 'savon'

# Wrapper around the http://www.nrel.gov/rredc/pvwatts/ web service API.
# Calculates the Performance of a Grid-Connected PV System. 
# Use of the Pvwatts web service is restricted to authorized users. 
# For information on obtaining authorization, contact bill_marion@nrel.gov
#
# @see http://www.nrel.gov/rredc/pvwatts/
#
# @author Matt Aimonetti for http://solaruniverse.com
#
class Pvwatts
  
  Savon::Request.log = false
  
  attr_reader :api_key
  
  # Create an instance of the API wrapper.
  #
  # @param [String] api_key The Pvwatts API key provided by bill_marion@nrel.gov
  #
  def initialize(api_key)
    @api_key = api_key
  end
  
  # Calculate the estimated yearly production based on passed options.
  #
  # @param [Hash] opts
  # @option opts [String, Float] :latitude Latitude coordinate of the location.
  # @option opts [String, Float] :longitude Longitude coordinate of the location.
  # @option opts [String, Float] :dc_rating kW rating values 0.5 to 10000.0
  # @option opts [String, Float] :tilt PV Array Lattitude tilt value 0 - 90
  # @option opts [String, Integer] :azimuth azimuth value 0 - 360 (180 for Northern Hemisphere).
  # @option opts [String, Float] :derate overall DC to AC derate factor values 0.10 - 0.96
  # @option opts [String, Float] :cost electricity cost per kWh (US ¢/kWh)
  # @options opts [String, Integer] :array_type 0=fixed tilt, 1=1-axis tracking, 2=2-axis tracking
  # @return [Hash] A hash with the yearly production with a key for each month and a 'year' key to represent the yearly value.
  #
  def yearly_production(opts={})
    Rails.logger.debug("pvwatts yearly prod called") if Object.const_defined?(:Rails)
    keys = opts.keys 
    client = Savon::Client.new("http://pvwatts.nrel.gov/PVWATTS.asmx?WSDL")
    @latitude, @longitude = [opts[:latitude], opts[:longitude]]
    @dc_rating, @tilt, @azimuth, @derate, @cost, @array_type  = opts[:dc_rating], opts[:tilt], opts[:azimuth], opts[:derate], opts[:cost], opts[:array_type]
    unless @latitude &&  @longitude &&  @dc_rating && @tilt && @azimuth &&  @derate && @cost && @array_type 
      raise ArgumentError, "passed -> latitude: #{@latitude}, longitude: #{@longitude}, dc_rating: #{@dc_rating}, tilt: #{@tilt}, azimuth: #{@azimuth}, derate: #{@derate}, cost: #{@cost}, array_type: #{@array_type}"
    end
    req = prep_request(@latitude, @longitude, @dc_rating, @tilt, @azimuth, @derate, @array_type, @cost)
    
    response = client.get_pvwatts{|soap| soap.input = "GetPVWATTS"; soap.body = req }
    rdata = response.to_hash
    if rdata[:get_pvwatts_response] && rdata[:get_pvwatts_response][:get_pvwatts_result] && rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo]
      @production_data = {}
      @pvwatt_info = rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo].compact
      @pvwatt_info.each do |el| 
        if el.respond_to?(:has_key?) && el.has_key?(:month)
          @production_data[el[:month].downcase] = el[:a_cenergy].to_i
        end
      end
    else
      raise 'Problem with the pvwatts response'
    end
    @production_data
  end
  # Get information based on passed options.
  #
  # @param [Hash] opts
  # @option opts [String, Float] :latitude Latitude coordinate of the location.
  # @option opts [String, Float] :longitude Longitude coordinate of the location.
  # @option opts [String, Float] :dc_rating kW rating values 0.5 to 10000.0
  # @option opts [String, Float] :tilt PV Array Lattitude tilt value 0 - 90
  # @option opts [String, Integer] :azimuth azimuth value 0 - 360 (180 for Northern Hemisphere).
  # @option opts [String, Float] :derate overall DC to AC derate factor values 0.10 - 0.96
  # @option opts [String, Float] :cost electricity cost per kWh (US ¢/kWh)
  # @options opts [String, Integer] :array_type 0=fixed tilt, 1=1-axis tracking, 2=2-axis tracking
  # @return [Hash] A hash with the yearly production with a key for each month and a 'year' key to represent the yearly value.
  #
  def get_stats(opts={})
    Rails.logger.debug("pvwatts get_stats called") if Object.const_defined?(:Rails)
    keys = opts.keys 
    client = Savon::Client.new("http://pvwatts.nrel.gov/PVWATTS.asmx?WSDL")
    @latitude, @longitude = [opts[:latitude], opts[:longitude]]
    @dc_rating, @tilt, @azimuth, @derate, @cost, @array_type  = opts[:dc_rating], opts[:tilt], opts[:azimuth], opts[:derate], opts[:cost], opts[:array_type]
    unless @latitude &&  @longitude &&  @dc_rating && @tilt && @azimuth &&  @derate && @cost && @array_type 
      raise ArgumentError, "passed -> latitude: #{@latitude}, longitude: #{@longitude}, dc_rating: #{@dc_rating}, tilt: #{@tilt}, azimuth: #{@azimuth}, derate: #{@derate}, cost: #{@cost}, array_type: #{@array_type}"
    end
    req = prep_request(@latitude, @longitude, @dc_rating, @tilt, @azimuth, @derate, @array_type, @cost)
    
    response = client.get_pvwatts{|soap| soap.input = "GetPVWATTS"; soap.body = req }
    rdata = response.to_hash
    if rdata[:get_pvwatts_response] && rdata[:get_pvwatts_response][:get_pvwatts_result] && rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo]
      @production_data = []
      @pvwatt_info = rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo].compact
      @production_data = @pvwatt_info
    else
      raise 'Problem with the pvwatts response'
    end
    @production_data
  end
  private
  
  def prep_request(latitude, longitude, dc_rating, tilt, azimuth, derate, array_type, cost)
    Rails.logger.debug "calling pvwatts with: latitude: #{latitude}, longitude: #{longitude}, dc_rating: #{dc_rating}, tilt: #{tilt}, azimuth: #{azimuth}, dc_derate: #{derate}, cost: #{cost}, array_type: #{array_type}" if Object.const_defined?(:Rails)
    { 'wsdl:key'        => api_key,
      'wsdl:latitude'   => latitude,
      'wsdl:longitude'  => longitude,
      'wsdl:locationID' => '', 
      'wsdl:DCrating'   => dc_rating, 
      'wsdl:derate'     => derate,
      'wsdl:cost'       => cost,
      'wsdl:mode'       => array_type,
      'wsdl:tilt'       => tilt,
      'wsdl:azimuth'    => azimuth,
      'wsdl:inoct'      => 45.0,
      'wsdl:pwrdgr'     => -0.005
    }
  end
  
end