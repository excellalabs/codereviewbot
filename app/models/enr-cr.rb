require 'slack-ruby-bot'

class EnrCr < SlackRubyBot::Bot
  command 'ping' do |client, data, match|
    client.say(text: 'pong', channel: data.channel)
  end
end

EnrCr.run