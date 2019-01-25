class Bot < SlackRubyBot::Bot
  command 'say' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end

  command 'shareMembers' do |client, data, match|
    slack = Slack::Web::Client.new
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    puts members
    members.each do |member|
      client.say(channel: data.channel, text: member)
    end
  end

  command 'info' do |client, data, match|
    puts data.to_hash
    client.say(channel: data.channel, text: data.to_hash)
  end

  command 'user-info' do |client, data, match|
    puts data.to_hash
    client.say(channel: data.channel, text: data.to_hash["user"])
    client.say(channel: data.channel, text: "<@#{data.to_hash["user"]}>_meh")
    client.say(channel: data.channel, text: "<#{data.to_hash["user"]}>")
  end


  operator 'enr-cr-reset' do |client, data, match|
    slack = Slack::Web::Client.new
    User.destroy_all
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    members.each do |user|
      User.create!(name: user)
    end
  end

  operator 'enr-cr' do |client, data, match|
    slack = Slack::Web::Client.new
    user = User.order("updated_at ASC").first
    user = User.order("updated_at ASC").second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>")
    user.touch
  end

  operator 'andon' do |client, data, match|
    client.say(channel: data.channel, text: "<!here CODE RED! Stop what you're doing. Find out what you can do to help.")
    if data.channel == ENV['CODE_RED_CHANNEL']
      ENV['TEAM_CHANNELS'].split(",").each do |channel|
        client.say(channel: channel, text: "!here CODE RED! Stop what you're doing. Find out what you can do to help.")
      end
    end
  end
end