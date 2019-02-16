class Bot < SlackRubyBot::Bot
  help do
    title 'Code Review Bot'
    desc 'This bot allows you to rotate through channel members for code reviews or pull requests'

    command 'channel-members' do
      desc 'Lists user ids in the channel so that you know who to exclude'
    end

    command 'cd-rv-exclude USERID1 USERID2' do
      desc 'Allows you to exclude members in a channel from getting selected'
    end

    command 'cd-rv-reset' do
      desc 'Set the list of users in the channel you can call. Run this command again if you add a user to the excluded list'
    end

    # command 'cd-rv' do
    #   desc 'This will rotate through the list of users previously set'
    # end
  end


  operator 'channel-members' do |client, data, match|
    slack = Slack::Web::Client.new
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    puts members
    members.each do |member|
      client.say(channel: data.channel, text: "#{member} - <@#{member}>", thread_ts: data.thread_ts || data.ts)
    end
  end

  command 'info' do |client, data, match|
    puts data.to_hash
    client.say(channel: data.channel, text: data.to_hash, thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv-reset' do |client, data, match|
    slack = Slack::Web::Client.new
    old_users = User.where(active: true, channel: data.channel)
    old_users.destroy_all
    members = slack.channels_info(channel: data.channel).to_hash["channel"]["members"]
    members_to_exclude = User.where(channel: data.channel, active: false).pluck(:name)
    members.reject! { |id| members_to_exclude.include?(id) }

    members.each do |user|
      User.create!(name: user, channel: data.channel)
    end
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

    client.say(channel: data.channel, text: "#{excluded_members.count} user(s) excluded", thread_ts: data.thread_ts || data.ts)
  end

  operator 'cd-rv' do |client, data, match|
    users = User.where(channel: data.channel, active: true).order("updated_at ASC")
    user = users.first
    user = users.second if user.name == data["user"]

    client.say(channel: data.channel, text: "<@#{user.name}>", thread_ts: data.thread_ts || data.ts)
    user.touch
  end

  operator 'clear-exclude' do |client, data, match|
    excluded_users = User.where(active: false, channel: data.channel)
    count = excluded_users.count
    excluded_users.destroy_all
    client.say(channel: data.channel, text: "#{count} user(s) no longer excluded in this channel", thread_ts: data.thread_ts || data.ts)
  end

  operator 'andon' do |client, data, match|
    slack = Slack::Web::Client.new
    channel_name = slack.channels_info(channel: data.channel).to_hash["channel"]["name"]

    Andon.create(channel: channel_name, issue: match['expression'])
    if data.channel == ENV['CODE_RED_CHANNEL']
      client.say(channel: data.channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      Bot.turn_on_silly_lights
      Bot.turn_on_bits_lights
      Bot.turn_on_faux_lights
      ENV['TEAM_CHANNELS'].split(",").each do |channel|
        client.say(channel: channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      end
    else
      client.say(channel: data.channel, text: "<!here> Stop what you're doing. Find out what you can do to help.")
      Bot.turn_on_lights(data.channel)
    end

  end

  operator 'add-device' do |client, data, match|
    Device.create(channel: data.channel, key: match['expression'])
  end

  operator 'lightsOn' do |client, data, match|
    Bot.turn_on_lights(data.channel)
  end

  operator 'sillyOn' do |client, data, match|
    Bot.turn_on_silly_lights
  end

  operator 'sillyOn' do |client, data, match|
    Bot.turn_on_silly_lights
  end

  operator 'sillyOff' do |client, data, match|
    Bot.turn_off_silly_lights
  end

  operator 'bitsOn' do |client, data, match|
    Bot.turn_on_bits_lights
  end

  operator 'bitsOff' do |client, data, match|
    Bot.turn_off_bits_lights
  end

  operator 'fauxOn' do |client, data, match|
    Bot.turn_on_faux_lights
  end

  operator 'fauxOff' do |client, data, match|
    Bot.turn_off_faux_lights
  end

  def self.turn_on_lights(channel)
    device = Device.where(channel: channel).first
    return unless device.any?

    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{device.key}"
    response = HTTParty.get(url)

    puts response.body
  end

  def self.turn_on_silly_lights
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{ENV['SILLIES_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

  def self.turn_off_silly_lights
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{ENV['SILLIES_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

  def self.turn_on_bits_lights
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{ENV['BITS_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

  def self.turn_off_bits_lights
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{ENV['BITS_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

  def self.turn_on_faux_lights
    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{ENV['FAUXPAS_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

  def self.turn_off_faux_lights
    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{ENV['FAUXPAS_IFTTT_KEY']}"
    response = HTTParty.get(url)
    puts response.body
  end

end