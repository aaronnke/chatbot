require 'wit'
require 'http'
require 'byebug'

access_token = 'G6PIL2LM6IPQMUR5AWYBLTNK6TB3VMQE'   # Wit.ai token
consumer_key = 'F5GTadW38nPVX9XCKSehpamZXU2YtBZK'   # data.gov.sg token

actions = {
  send: -> (request, response) {
    puts("sending... #{response['text']}")
  },
  my_action: -> (request) {
    return request['context']
  },
}

client = Wit.new(access_token: access_token, actions: actions)

rsp = client.message(ARGV[0])
entities = rsp['entities']
intent = entities['intent'][0]['value'] if entities['intent']
date_time = entities['datetime'] ? entities['datetime'][0]['value'].slice(0,19) : nil
location = entities['location'][0]['value'].upcase if entities['location']
reply = nil
case intent
when 'air_temperature'
  url = "https://api.data.gov.sg/v1/environment/air-temperature"
  url += "?date_time=#{date_time}" if date_time
  data = HTTP.headers('api-key' => consumer_key).get(url)
  temp = data.parse['items'][0]['readings'][0]['value']
  reply = "The temperature was #{temp} at #{date_time}"
when 'weather'
  url = "https://api.data.gov.sg/v1/environment/2-hour-weather-forecast"
  url += "?date_time=#{date_time}" if date_time
  data = HTTP.headers('api-key' => consumer_key).get(url).parse['items'][0]
  start_time = data['valid_period']['start'].slice(0,19)
  end_time = data['valid_period']['end'].slice(0,19)
  index = data['forecasts'].index{ |loc| loc['area'].upcase == location }
  forecast = data['forecasts'][index]['forecast']
  reply = "The forecast for #{location} between #{start_time} and #{end_time} is #{forecast}"
when 'joke'
  joke_type = entities['joke_type'] ? entities['joke_type'][0]['value'] : 'lame'
  contact = entities['contact'] ? entities['contact'][0]['value'] : 'you'
  joke = nil
  case joke_type
  when 'lame'
    joke = "What is Transformer's sister called? Transistor!"
  when 'sad'
    joke = "There once was a frog who was so ugly everyone died."
  end
  reply = "Hey #{contact}, #{joke}."
end

puts reply
