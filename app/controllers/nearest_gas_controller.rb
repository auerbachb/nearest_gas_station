require 'open-uri'

class NearestGasController < ApplicationController

  GOOGLE_MAP_KEY = 'AIzaSyAIU_2CxK-fAGA7WLz6AR_6IDBfshuDzvE'
  REVESE_GPS_QUERY_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=%s,%s&key=%s'
  GAS_STATION_QUERY_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%s,%s&type=gas_station&keyword=gas station&rankby=distance&key=%s'
  GEOCODING_QUERY_URL = 'https://maps.googleapis.com/maps/api/geocode/json?address=%s&key=%s'

  def index
    permitted = params.permit(:lat, :lng)
    if !permitted.permitted?
      render json: {
        error: 'params are invalid'
      }
      return
    end
    lat = params[:lat]
    lng = params[:lng]
    address = reverse_gps(lat, lng)
    if address == nil
      render json: {
        error: 'latitude and longitude not found'
      }, status: :not_found
      return
    end
    nearest_gas_station = fetch_nearest_gas_station(lat, lng)
    NearestGasStaion.create({
        lat: lat,
        lng: lng,
        address: address,
        nearest_gas_station: nearest_gas_station
    })
    render json: {
      address: address,
      nearest_gas_station: nearest_gas_station
    }
  end

  def fetch_nearest_gas_station(lat, lng)
    formatted_gas_station_query_url = format(GAS_STATION_QUERY_URL, lat, lng, GOOGLE_MAP_KEY)
    begin
      gas_station_address = JSON.parse(open(formatted_gas_station_query_url).read)['results'][0]['vicinity']
      formatted_geocoding_query_url = format(GEOCODING_QUERY_URL, gas_station_address, GOOGLE_MAP_KEY)
      address_components = JSON.parse(open(formatted_geocoding_query_url).read)['results'][0]['address_components']
      return parse_address_components(address_components)
    rescue Exception => e
      return {}
    end
  end


  def reverse_gps(lat, lng)
    formatted_reverse_gps_query_url = format(REVESE_GPS_QUERY_URL, lat, lng, GOOGLE_MAP_KEY)
    begin
      address_components = JSON.parse(open(formatted_reverse_gps_query_url).read)['results'][0]['address_components']
      return parse_address_components(address_components)
    rescue Exception => e
      return nil
    end
  end

  def parse_address_components(address_components)
    parsed_address_components = {}
      address_components.each{ |address_component|
        types = address_component['types']
        if types.include? 'street_number'
          parsed_address_components['street_number'] = address_component['long_name']
        elsif types.include? 'route'
          parsed_address_components['route'] = address_component['long_name']
        elsif types.include? 'locality'
          parsed_address_components['city'] = address_component['long_name']
        elsif types.include? 'administrative_area_level_1'
          parsed_address_components['state'] = address_component['short_name']
        elsif types.include? 'postal_code'
          parsed_address_components['postal_code'] = address_component['long_name']
        elsif types.include? 'postal_code_suffix'
          parsed_address_components['postal_code_suffix'] = address_component['long_name']
        end
      }
      postal_code = ''
      if parsed_address_components.key?('postal_code_suffix') && parsed_address_components['postal_code_suffix'] != ''
        postal_code = format('%s-%s', parsed_address_components['postal_code'], parsed_address_components['postal_code_suffix'])
      else
        postal_code = parsed_address_components['postal_code']
      end
      street_address = ''
      if parsed_address_components.key?('route') && parsed_address_components['route'] != ''
        street_address = format('%s %s', parsed_address_components['street_number'], parsed_address_components['route'])
      else
        street_address = parsed_address_components['street_number']
      end
      address = {
        'streetAddress': street_address,
        'city': parsed_address_components['city'],
        'state': parsed_address_components['state'],
        'postalCode': postal_code
      }
      return address
  end
end
