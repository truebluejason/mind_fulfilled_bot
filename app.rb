require 'sinatra'

# Talk to Facebook
get '/mybot' do
	params['hub.challenge'] if ENV['verify_token'] == params['hub.verify_token']
end

get '/' do
	"Jason and Ellen, UBC Local Hack Day 2017."
end

# ACCESS_TOKEN=EAACJA49QhH4BAKJTbBoSp8hUf7BHygHJyBwijKOjO8pua0hWTZAkac43eyhjJgULc0hZCNdwnJkDMyEV3gxi7CaMXEItyzms7z1rklyvgJZCK3bo54WWcDyTcOUYAExR4ZBfTgwimTZBiLYmEjygDIIcsYnxjB9ITTWoHjJxFAAZDZD
# Page token ^
# VERIFY_TOKEN=iloveellen
# Token for webhook verification ^