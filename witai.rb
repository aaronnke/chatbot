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

reply = nil
case intent
when 'air_temperature'
  url = "https://api.data.gov.sg/v1/environment/air-temperature"
  data = HTTP.headers('api-key' => consumer_key).get(url)
  temp = data.parse['items'][0]['readings'][0]['value']
  reply = "The temperature is #{temp}"
end

puts reply
