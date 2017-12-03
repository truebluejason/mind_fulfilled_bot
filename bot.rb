require 'facebook/messenger'
require 'byebug'
require_relative 'chat_menu'
require_relative 'intro'
require_relative 'helpers'
include Facebook::Messenger
include EasyAPI

PAYLOADS = {
	menu_reason: 'EXPLAIN',
	menu_act: 'ACTION',
	menu_show_specific: 'SPECIFIC',
	menu_show_all: 'SHOW_ALL',
	start: 'GET_STARTED_PAYLOAD',
	learn_more: 'LEARN',
	begin_routine: 'BEGIN',
	mood_good: 'CONTENT',
	mood_okay: 'OKAY',
	mood_bad: 'DISCONTENT',
	submit_yes: 'SUBMIT',
	submit_no: 'RETRY'
}

# Subscribe to Facebook webhook
Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

# Enable Facebook chat menu functionalities and greets the user
Intro.enable
ChatMenu.enable

# Handle Postback
Facebook::Messenger::Bot.on :postback do |postback|
	@user_id = postback.sender['id']
	puts "Received payload: #{postback.payload} from user with ID: #{@user_id}"
	case postback.payload
	# Bot's introduction
	when PAYLOADS[:start]
		sleep 2
		text_reply(postback, "I'm Mind Fulfilled Bot, a Facebook chatbot
			 designed to try help you feel more content and grateful living your life.")
		sleep 2
		button_reply(postback,"Please tap 'Learn more' to learn more about how I work.",
			[{type: 'postback', title: 'Learn more', payload: PAYLOADS[:learn_more]}])
	when PAYLOADS[:learn_more]
		sleep 2
		text_reply(postback, "I work by messaging you once per day at night to 
			reflect how you felt and to tell me one thing that you were grateful about that day.")
		sleep 2
		text_reply(postback, "Please click on the menu on the bottom of the screen to
			 see more options, such as why what I do can help you be happier.")
		sleep 2
		button_reply(postback,"If you are ready to proceed, please tap 'Begin my journey'.",
			[{type: 'postback', title: 'Begin my journey', payload: 'BEGIN'}])
	when PAYLOADS[:begin_routine]
		standard_reminder
	when PAYLOADS[:mood_good]
		byebug
		text_reply(postback, "I'm happy for you :)")
		text_reply(postback, "Can you tell me one thing that happened today that you were thankful about?")
		wait_for_gratefulness_input
	when PAYLOADS[:mood_okay]
		text_reply(postback, "I'm glad your day wasn't too hard!")
		text_reply(postback, "Can you tell me one thing that happened today that you were thankful about?")
		wait_for_gratefulness_input
	when PAYLOADS[:mood_bad]
		text_reply(postback, "That's too bad.. I hope that tomorrow will be a happier day for you.")
		text_reply(postback, "You can always find something to be grateful for – even during the worst moments!")
		text_reply(postback, "Can you tell me one thing that happened today that you were thankful about?")
		wait_for_gratefulness_input
	when PAYLOADS[:submit_yes]
		sleep 2
		text_reply(postback, 'Great to hear.')
		sleep 2
		text_reply(postback, "Thanks! I'm glad to be of help to you.")
		sleep 2
		text_reply(postback, "Please feel free to interact with me further as specified in the menu.
			 Else, I'll see you tomorrow!")
		lay_low_until_reminder
	when PAYLOADS[:submit_no]
		text_reply(postback, "I'd love to hear your response again.")
		wait_for_gratefulness_input
	else
		puts 'Unrecognized Payload'
	end
end

# Handle Start + Menu related postbacks
Bot.on :postback do |postback|
	@user_id = postback.sender['id']
	postback.mark_seen
	case postback.payload
	when PAYLOADS[:menu_reason]
	when PAYLOADS[:menu_act]
	when PAYLOADS[:menu_show_specific]
	when PAYLOADS[:menu_show_all]
	end
end

def lay_low_until_reminder
	Bot.on :message do |message|
		message.reply(text: "This is a test msg.")
	end
end

# Routine that asks user to rate their day and logs his grateful message
def standard_reminder
	message_options = {
		recipient: {id: @user_id},
		message: {
			attachment: {
			type: 'template',
			payload: {
					template_type: 'button',
					text: "How did you feel today?",
					buttons: [
						{type: 'postback', title: 'Content', payload: PAYLOADS[:mood_good]},
						{type: 'postback', title: 'Okay', payload: PAYLOADS[:mood_okay]},
						{type: 'postback', title: 'Discontent', payload: PAYLOADS[:mood_bad]}
					]
			}
				}
			}
	}
	Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
end

# Accepts user's gratefulness post and asks for confirmation through postback
def wait_for_gratefulness_input
	
	Bot.on :message do |message|
		received = message.text
		button_reply(message, "Confirm your answer of '#{received}'?",
			[{type: 'postback', title: 'Yes', payload: PAYLOADS[:submit_yes]},
			{type: 'postback', title: 'No', payload: PAYLOADS[:submit_no]}])
	end
end