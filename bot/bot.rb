class Bot < SlackRubyBot::Bot
  command 'say' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end

  operator 'share members' do |client, data, match|
    slack = Slack::Web::Client.new
    puts data.channel
    puts '*' * 25
    puts data.channel.members
    puts '*' * 25
    puts data.channel.to_h
    client.say(channel: data.channel, text: slack.channels_info(channel: data.channel.members))
  end

  command 'share' do |client, data, match|
    slack = Slack::Web::Client.new
    client.say(channel: data.channel, text: slack.channels_info(channel: data.channel))
  end


  operator 'enr-cr-reset' do |client, data, match|
    slack = Slack::Web::Client.new
    User.destroy_all
    slack.channels_info(channel: data.channel).members.each do |user|
      User.create!(name: user)
    end
  end

  operator 'enr-cr' do |client, data, match|
    slack = Slack::Web::Client.new
    user = User.order("updated_at ASC").first
    client.say(channel: data.channel, text: user)
    user.touch
  end



end