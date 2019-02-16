class CodeReviewBot < SlackRubyBot::Bot
  operator 'cd-rv' do |client, data, match|
    users = User.where(channel: data.channel, active: true).order("updated_at ASC")
    user = users.first
    user = users.second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>", thread_ts: data.thread_ts || data.ts)
    user.touch
  end
end