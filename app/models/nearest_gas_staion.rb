class NearestGasStaion
  include Mongoid::Document
  field :lat, type: String
  field :lng, type: String
  field :address, type: Hash
  field :nearest_gas_station, type: Hash
end
