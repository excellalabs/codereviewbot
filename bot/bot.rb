class Bot < SlackRubyBot::Bot
  command 'say' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end


  command 'share' do |client, data, match|
    slack = Slack::Web::Client.new
    client.say(channel: data.channel, text: slack.channels_info(channel: data.channel))
  end
end