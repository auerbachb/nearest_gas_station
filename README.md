# README
## A rails API-only project.
Given a gps, return address and nearest gas station using google map API.

### Function
GET ```http://localhost:3000/nearest_gas?lat=37.778015&lng=-122.412272```

Response
```
{
  "address": {
    "streetAddress": "21 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021-3100"
  },
"nearest_gas_station": {
    "streetAddress": "55 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021-3100"
  }

}
```

Insert query log into local mongoDB
```
{ 
    "_id" : ObjectId("5a0710f9b26e3cf7ea69752d"), 
    "lat" : "37.778015", 
    "lng" : "-122.412272", 
    "address" : {
        "streetAddress" : "1161 Mission Street", 
        "city" : "San Francisco", 
        "state" : "CA", 
        "postalCode" : "94103"
    }, 
    "nearest_gas_station" : {
        "streetAddress" : "1298 Howard Street", 
        "city" : "San Francisco", 
        "state" : "CA", 
        "postalCode" : "94103-2712"
    }
}
```

### Testing
run ```rails test test/controllers/nearest_gas_controller_test.rb```

### Problem
**Problem when reversing gps**

For the example gps [37.77801, -122.4119], I sent a query to google map API

```https://maps.googleapis.com/maps/api/geocode/json?latlng=37.77801,-122.4119076&key=AIzaSyAIU_2CxK-fAGA7WLz6AR_6IDBfshuDzvE```

But it returns more than one result where none of them is '1161 Mission St, San Francisco, CA 94103'.

A note from google map API, '***Reverse geocoding is an estimate. The geocoder will attempt to find the closest addressable location within a certain tolerance. If no match is found, the geocoder will return zero results***'. Therefore, reversing a gps will only return some possible addresses. One address is matched to one gps, but one gps is matched to many possible addressed.

However, if I use geocoding API(address to gps) 

```https://maps.googleapis.com/maps/api/geocode/json?address=1161%20Mission%20St,%20San%20Francisco,%20CA%2094103&key=AIzaSyAIU_2CxK-fAGA7WLz6AR_6IDBfshuDzvE```

to query address `1161 Mission St, San Francisco, CA 94103`, it returns a gps `[37.7779056, -122.4120423]` that will be found in the first result of response from gps reverse API(gps to address) ```https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7779056,-122.4120423&key=AIzaSyAIU_2CxK-fAGA7WLz6AR_6IDBfshuDzvE```.

I think this gps should be the most precise one.

Considering of the situation above, when reversing a gps, my method is extracting the first result of the response from gps reverse API. When doing testing, my first step is to get the most precise gps from geocoding API, eg: 1161 Mission St, San Francisco, CA 94103 => [37.7779056, -122.4120423], and then only compare the nearest address of gas station.

