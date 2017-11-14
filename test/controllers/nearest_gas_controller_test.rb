require 'test_helper'

class NearestGasControllerTest < ActionDispatch::IntegrationTest
  test '1161 Mission St, San Francisco, CA 94103, gps: [37.7779056, -122.4120423]' do
    expected_nearest_gas_station = {
      'streetAddress' => '1298 Howard Street',
      'city' => 'San Francisco',
      'state' => 'CA',
      'postalCode' => '94103-2712'
    }
    get 'http://localhost:3000/nearest_gas?lat=37.778015&lng=-122.412272'
    assert_equal(expected_nearest_gas_station, JSON.parse(response.body)['nearest_gas_station'], 'success')
  end

  test '469 7th Ave, New York, NY 10018, gps: [40.75194, -73.9894451]' do
    # In this case, the google map api returns '1 Pennsylvania Plaza # 1612, New York' which is a fuel company.
    # But when searching within google map, the nearest gas station should be '466 10th Avenue, New York' that is a BP gas staion.
    # Suggestion: Check if its name is one of the gas staion brand in usa.

    expected_nearest_gas_station = {
      'streetAddress' => '466 10th Avenue',
      'city' => 'New York',
      'state' => 'NY',
      'postalCode' => '10018-1112'
    }
    get 'http://localhost:3000/nearest_gas?lat=40.75194&lng=-73.9894451'
    assert_equal(expected_nearest_gas_station, JSON.parse(response.body)['nearest_gas_station'], 'success')
  end

  test 'gps located at a gas station, 466 10th Avenue, manhattan, gps: [40.7559917, -73.9978144]' do
    # It should return itself.

    expected_nearest_gas_station = {
      'streetAddress' => '466 10th Avenue',
      'city' => 'New York',
      'state' => 'NY',
      'postalCode' => '10018-1112'
    }
    get 'http://localhost:3000/nearest_gas?lat=40.7559917&lng=-73.9978144'
    assert_equal(expected_nearest_gas_station, JSON.parse(response.body)['nearest_gas_station'], 'success')
  end

  test 'invalid gps' do
    expected_response = {
      'error' => 'latitude and longitude not found'
    }
    get 'http://localhost:3000/nearest_gas?lat=hello&lng=-122.412272'
    assert_equal(expected_response, JSON.parse(response.body), 'success')
  end

  test 'ignore extra params' do
    expected_nearest_gas_station = {
      'streetAddress' => '1298 Howard Street',
      'city' => 'San Francisco',
      'state' => 'CA',
      'postalCode' => '94103-2712'
    }
    get 'http://localhost:3000/nearest_gas?lat=37.778015&lng=-122.412272&xx=ok'
    assert_equal(expected_nearest_gas_station, JSON.parse(response.body)['nearest_gas_station'], 'success')
  end

  test 'a gps in the middle of sea' do
    # No address and gas station found.
    
    expected_response = {
      'addresses' => [],
      'nearest_gas_station' => {}
    }
    get 'http://localhost:3000/nearest_gas?lat=24.508053&lng=-92.175429'
    assert_equal(expected_response, JSON.parse(response.body), 'success')
  end
end
