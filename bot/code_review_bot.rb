class CodeReviewBot < SlackRubyBot::Bot
  help do
    title 'Code Review Bot'
    desc 'This bot allows you to rotate through channel members for code reviews or pull requests'

    command 'cd-rv-set' do
      desc 'Set the initial list of users in the channel you can call'
    end

    command 'cd-rv-exclude USERID1 USERID2' do
      desc 'Allows you to exclude members in a channel from getting selected'
    end

    command 'cd-rv' do
      desc 'This will rotate through the list of users previously set'
    end

    command 'cd-rv-list' do
      desc 'Lists user that are part of the code review list'
    end

    command 'cd-rv-exclude-list' do
      desc 'Lists user that are excluded from code review'
    end

    command 'channel-members' do
      desc 'Lists user ids in the channel'
    end

    command 'cd-rv-add' do
      desc 'Adds a user to the code review list'
    end

  end

  operator 'cd-rv-set' do |client, data, match|
    CodeReviewBot.set_code_review_list(data.channel)
  end

  operator 'cd-rv-exclude-list' do |client, data, match|
    slack = Slack::Web::Client.new
    excluded_users = User.where(active: false, channel: data.channel).pluck(:name)
    excluded_names = []

    excluded_users.each do |user|
      name = slack.users_info(user: user.strip.gsub(/[<@>]/, "")).to_hash["user"]["real_name"]
      excluded_names.push(name)
    end

    client.say(channel: data.channel, text: excluded_names, thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv-list' do |client, data, match|
    slack = Slack::Web::Client.new
    active_members = User.where(active: true, channel: data.channel).order("updated_at ASC").pluck(:name)
    active_names = []

    active_members.each do |user|
      slack_user = slack.users_info(user: user.strip.gsub(/[<@>]/, "")).to_hash["user"]
      name = slack_user["real_name"]
      id = slack_user["id"]

      channel_member = "#{name} - #{id}"
      active_names.push(channel_member)
    end

    client.say(channel: data.channel, text: active_names, thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv-exclude' do |client, data, match|
    slack = Slack::Web::Client.new
    excluded_members = match['expression'].split(",")

    excluded_members.each do |user|
      user_id = slack.users_info(user: user.strip.gsub(/[<@>]/, "")).to_hash["user"]["id"]
      User.create!(name: user_id, channel: data.channel, active: false)
    end

    CodeReviewBot.set_code_review_list(data.channel)
    client.say(channel: data.channel, text: "#{excluded_members.count} user(s) excluded", thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv-add' do |client, data, match|
    slack = Slack::Web::Client.new

    members_to_add = match['expression'].split(",")
    members_to_add.each do |user|
      user_id = slack.users_info(user: user.strip.gsub(/[<@>]/, "")).to_hash["user"]["id"]
      existing_user = User.where(channel: data.channel, name: user_id).first
      existing_user.destroy if existing_user
      User.create!(name: user_id, channel: data.channel)
    end

    client.say(channel: data.channel, text: "#{members_to_add.count} user(s) added to code review", thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv' do |client, data, match|
    users = User.where(channel: data.channel, active: true).order("updated_at ASC")
    user = users.first
    user = users.second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>", thread_ts: data.thread_ts || data.ts)
    user.touch
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