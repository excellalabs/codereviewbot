class CodeReviewBot < SlackRubyBot::Bot
  help do
    title 'Code Review Bot'
    desc 'This bot allows you to rotate through channel members for code reviews or pull requests'

    command 'channel-members' do
      desc 'Lists user ids in the channel so that you know who to exclude'
    end

    command 'cd-rv-exclude USERID1 USERID2' do
      desc 'Allows you to exclude members in a channel from getting selected'
    end

    command 'cd-rv-set' do
      desc 'Set the initial list of users in the channel you can call'
    end

    command 'cd-rv' do
      desc 'This will rotate through the list of users previously set'
    end
  end

  operator 'cd-rv-set' do |client, data, match|
    CodeReviewBot.set_code_review_list(data.channel)
  end

  operator 'cd-rv-exclude-list' do |client, data, match|
    excluded_users = User.where(active: false, channel: data.channel).pluck(:name)
    client.say(channel: data.channel, text: excluded_users, thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv-exclude' do |client, data, match|
    excluded_members = match['expression'].split(",")
    excluded_members.each do |user|
      User.create!(name: user.strip, channel: data.channel, active: false)
    end

    CodeReviewBot.set_code_review_list(data.channel)
    client.say(channel: data.channel, text: "#{excluded_members.count} user(s) excluded", thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv' do |client, data, match|
    users = User.where(channel: data.channel, active: true).order("updated_at ASC")
    user = users.first
    user = users.second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>", thread_ts: data.thread_ts || data.ts)
    user.touch
  end

  operator 'clear-excluded' do |client, data, match|
    excluded_users = User.where(active: false, channel: data.channel)
    count = excluded_users.count
    excluded_users.destroy_all
    client.say(channel: data.channel, text: "#{count} user(s) no longer excluded in this channel", thread_ts: data.thread_ts || data.ts)
  end

  def self.set_code_review_list(channel)
    slack = Slack::Web::Client.new
    old_users = User.where(active: true, channel: channel)
    old_users.destroy_all

    members = slack.channels_info(channel: channel).to_hash["channel"]["members"]
    members_to_exclude = User.where(channel: channel, active: false).pluck(:name)
    members.reject! { |id| members_to_exclude.include?(id) }

    members.each do |user|
      User.create!(name: user, channel: channel)
    end
  end
end