class Bot < SlackRubyBot::Bot
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

  operator 'andon' do |client, data, match|
    slack = Slack::Web::Client.new
    channel_name = slack.channels_info(channel: data.channel).to_hash["channel"]["name"]

    Andon.create(channel: channel_name, issue: match['expression'])
    if data.channel == ENV['CODE_RED_CHANNEL']
      client.say(channel: data.channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      Bot.eve_lights_on
      sleep(30)
      Bot.eve_lights_off
    else
      client.say(channel: data.channel, text: "<!here> Stop what you're doing. Find out what you can do to help.")
      Bot.turn_on_lights(data.channel)
      sleep(30)
      Bot.turn_off_lights(data.channel)
    end

  end

  operator 'add-device' do |client, data, match|
    Device.create(channel: data.channel, key: match['expression'])
  end

  operator 'lightsOn' do |client, data, match|
    Bot.turn_on_lights(data.channel)
  end

  operator 'lightsOff' do |client, data, match|
    Bot.turn_off_lights(data.channel)
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
    device = Device.where(channel: channel)
    return unless device.any?

    url = "https://maker.ifttt.com/trigger/lights_on/with/key/#{device.first.key.strip}"
    response = HTTParty.get(url)

    puts response.body
  end

  def self.turn_off_lights(channel)
    device = Device.where(channel: channel)
    return unless device.any?

    url = "https://maker.ifttt.com/trigger/lights_off/with/key/#{device.first.key.strip}"
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

  def self.eve_lights_on
    ENV['TEAM_CHANNELS'].split(",").each do |channel|
      client.say(channel: channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      Bot.turn_on_lights(channel)
    end
  end

  def self.eve_lights_off
    ENV['TEAM_CHANNELS'].split(",").each do |channel|
      client.say(channel: channel, text: "<!here> CODE RED! Stop what you're doing. Find out what you can do to help.")
      Bot.turn_off_lights(channel)
    end
  end
end