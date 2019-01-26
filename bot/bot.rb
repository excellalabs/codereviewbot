class Bot < SlackRubyBot::Bot
  command 'say' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end

  command 'channel-members' do |client, data, match|
    slack = Slack::Web::Client.new
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    puts members
    members.each do |member|
      client.say(channel: data.channel, text: "#{member} - <@#{member}>")
    end
  end

  command 'info' do |client, data, match|
    puts data.to_hash
    client.say(channel: data.channel, text: data.to_hash)
  end

  operator 'code-review-reset' do |client, data, match|
    slack = Slack::Web::Client.new
    User.where(active: true, channel: data.channel).destroy_all
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    members_to_exclude =  User.where(active: false).pluck(:name)
    members.reject! { |id| members_to_exclude.include?(id) }
    members.each do |user|
      User.create!(name: user, channel: data.channel)
    end
  end

  operator 'code-review' do |client, data, match|
    user = User.where(channel: data.channel).order("updated_at ASC").first
    user = User.where(channel: data.channel).order("updated_at ASC").second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>")
    user.touch
  end

  operator 'cr-exclude' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end

  operator 'cr-excluded-list' do |client, data, match|
    excluded_users = User.where(active: false, channel: data.channel) || 'Currently Empty'
    client.say(channel: data.channel, text: match['expression'])
    client.say(channel: data.channel, text: excluded_users)
  end

  operator 'andon' do |client, data, match|
    client.say(channel: data.channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
    if data.channel == ENV['CODE_RED_CHANNEL']
      ENV['TEAM_CHANNELS'].split(",").each do |channel|
        client.say(channel: channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      end
    end
  end
end