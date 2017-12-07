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


def handle_start
	Bot.on :postback do |postback|
		@user_id = postback.sender['id']
		postback.mark_seen
		if postback.payload == PAYLOADS[:start]
			puts "Received Postback #{postback.payload}, going to introduction from handle_start"
			introduction postback
		else
			puts "Received Postback #{postback.payload}, going to handle_menu from handle_start"
			handle_menu postback
		end
	end
end
# Handle Start + Menu related postbacks
def handle_menu pb
	puts "At handle_menu, with postback: #{pb}"
	case pb.payload
	when PAYLOADS[:menu_reason]
		explain_benefits pb
	when PAYLOADS[:menu_act]
	when PAYLOADS[:menu_show_specific]
	when PAYLOADS[:menu_show_all]
	end
end

def explain_benefits pb
	text_reply(pb, "Studies have shown that cultivating thankfulness
	 on a daily basis can improve people's quality of life.")
	text_reply(pb, "Here are some links to different articles and papers, so you
	 can see the results and assess the benefits for yourself.")
	text_reply(pb, 'https://www.health.harvard.edu/newsletter_article/in-praise-of-gratitude')
	text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/12585811')
	text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/20515249')
	on_any_postback
end

# Intro interaction
def introduction pb
	text_reply(pb, "I'm Mind Fulfilled Bot, a Facebook chatbot
		 designed to try help you feel more content and grateful living your life.")
	button_reply(pb,"Please tap 'Learn more' to learn more about how I work.",
		[{type: 'postback', title: 'Learn more', payload: PAYLOADS[:learn_more]}])

	Bot.on :postback do |postback|
		puts postback.payload
		case postback.payload 
		when PAYLOADS[:learn_more]
			text_reply(postback, "I work by messaging you once per day at night to 
				reflect how you felt and to tell me one thing that you were grateful about that day.")
			text_reply(postback, "Please click on the menu on the bottom of the screen to
				 see more options, such as why what I do can help you be happier.")
			button_reply(postback,"If you are ready to proceed, please tap 'Begin my journey'.",
				[{type: 'postback', title: 'Begin my journey', payload: 'BEGIN'}])
			puts "Received Postback #{postback.payload}, going to begin_routine from introduction"
			begin_routine
		else
			puts "Received Postback #{postback.payload}, going to handle_menu from introduction"
			handle_menu postback
		end
	end
end

# Start the logging routine for the first time
def begin_routine
	Bot.on :postback do |postback|
		puts postback.payload
		case postback.payload
		when PAYLOADS[:begin_routine]
			puts "Received Postback #{postback.payload}, going to standard_reminder from begin_routine"
			standard_reminder
		else
			puts "Received Postback #{postback.payload}, going to handle_menu from begin_routine"
			handle_menu postback
		end
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
	Bot.on :postback do |postback|
		puts postback.payload
		case postback.payload
		when PAYLOADS[:mood_good]
			text_reply(postback, "I'm happy for you :)")
			text_reply(postback, "What's one thing about today that you can be happy about?")
			puts "Received Postback #{postback.payload}, going to wait_for_gratefulness_input from standard_reminder"
			wait_for_gratefulness_input
		when PAYLOADS[:mood_okay]
			text_reply(postback, "I'm glad your day wasn't too hard!")
			text_reply(postback, "What's one thing about today that you can be happy about?")
			puts "Received Postback #{postback.payload}, going to wait_for_gratefulness_input from standard_reminder"
			wait_for_gratefulness_input
		when PAYLOADS[:mood_bad]
			text_reply(postback, "That's too bad.. I hope that tomorrow will be a happier day for you.")
			text_reply(postback, "You can always find something to be grateful for – even during the worst moments!")
			text_reply(postback, "What's one thing about today that you can be happy about?")
			puts "Received Postback #{postback.payload}, going to wait_for_gratefulness_input from standard_reminder"
			wait_for_gratefulness_input	
		else
			puts "Received Postback #{postback.payload}, going to handle_menu from standard_reminder"
			handle_menu postback
		end
	end
end

# Accepts user's gratefulness post and asks for confirmation through postback
def wait_for_gratefulness_input
	Bot.on :message do |message|
		received = message.text
		button_reply(message, "Confirm your answer of '#{received}'?",
			[{type: 'postback', title: 'Yes', payload: PAYLOADS[:submit_yes]},
			{type: 'postback', title: 'No', payload: PAYLOADS[:submit_no]}])
	end
	Bot.on :postback do |postback|
		puts postback.payload
		case postback.payload
		when PAYLOADS[:submit_yes]
			text_reply(postback, 'Great to hear.')
			text_reply(postback, "Thanks! I'm glad to be of help to you.")
			text_reply(postback, "Please feel free to interact with me further as specified in the menu.
			 Else, I'll see you tomorrow!")
			puts "Received Postback #{postback.payload}, going to handle_menu from wait_for_gratefulness_input"
			handle_menu
		when PAYLOADS[:submit_no]
			text_reply(postback, "I'd love to hear your response again.")
			puts "Received Postback #{postback.payload}, going to wait_for_gratefulness_input from wait_for_gratefulness_input"
			wait_for_gratefulness_input
		else
			puts "Received Postback #{postback.payload}, going to handle_menu from wait_for_gratefulness_input"
			handle_menu postback
		end
	end
end

# Redirects to handle_menu on any postback
def on_any_postback
	Bot.on :postback do |postback|
		puts "Received Postback #{postback.payload}, going to handle_menu from on_any_postback"
		handle_menu postback
	end
end

handle_start