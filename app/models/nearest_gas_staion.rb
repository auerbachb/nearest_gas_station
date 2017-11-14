class NearestGasStaion
  include Mongoid::Document
  field :lat, type: String
  field :lng, type: String
  field :addresses, type: Array
  field :nearest_gas_station, type: Hash
end
