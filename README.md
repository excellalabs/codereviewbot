# evebot
A hubot that should contain all the bot functions that are used by everify. Functions such as enr-cr should be moved to this bot.

Currenly, evebot is set up to listen for an andon cord message. It will work only in the fauxpas and eve_code_red channel. Folders have been created for the big sillies and bits plase teams to create their own scripts.

### Local Development
1. Clone the repo.
2. Run `npm instlal`
3. Write code
4. Run the bot locally with `HUBOT_SLACK_TOKEN=<your_token_here>./bin/hubot -a slack`

You need two things for this. A Slack workspace where you can add hubot. I suggest creating your own personal Slack workspace. Click on the worspace name, got to Administration > Manage apps.

Slack will give you a token for the app. You'll use that in place of `<your_token_here>`. No `<>` of course.

If you need to add any other env vars (such as IFTTT keys for fancy lights), then you'll need to add those to your `.bash_profile` or prepend them to the start up command just like you do with HUBOT_SLACK_TOKEN. You must also give those envs to Joe Hunt and he will add them to Heroku (the server that makes this work).

### Scriping Guidlines
See the hubot scripting documentation here https://hubot.github.com/docs/scripting/

The general pattern is: Listeners go in files directly under `/scripts` and handlers go in your channel specific folder.

Robot listeners (`robot.hear`) must be placed directly under the `/scripts` folder. They will not automatically load in any other folder.

Create a listener, and then handle it using a Coffeescript class created in your team folder. Your class should inherit from `channelResponder.coffee`, which will restrict your command to your channel. To make this work you must pass in the channel id into the call to `super()` in the constructor. See the `/scripts/faux_pas/fauxPas.coffee` script for an example.

If you don't know what your channel id is, just write the code first. Then run the command in your channel. The command will respond with a helpful message telling you what the channel id is. :-)
