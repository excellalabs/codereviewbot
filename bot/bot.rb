class Bot < SlackRubyBot::Bot
  command 'say' do |client, data, match|
    client.say(channel: data.channel, text: match['expression'])
  end

  command 'share members' do |client, data, match|
    slack = Slack::Web::Client.new
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    client.say(channel: data.channel, text: members)
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
    client.say(channel: data.channel, text: user)
    user.touch
  end



end