require 'facebook/messenger'
require 'sequel'
require 'byebug'
require_relative 'chat_menu'
require_relative 'database_manager'
require_relative 'helpers'
require_relative 'intro'
require_relative 'postback_manager'
include Facebook::Messenger
include EasyAPI

DB = Sequel.connect('sqlite://user_logs.db')
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

def default_validations
	[PAYLOADS[:start], PAYLOADS[:menu_reason], PAYLOADS[:menu_act], PAYLOADS[:menu_show_specific], PAYLOADS[:menu_show_all]]
end

# Subscribe to Facebook webhook
Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

# Enable Facebook chat menu functionalities and greets the user
Intro.enable
ChatMenu.enable
DBManager.create_user_table
PostbackManager.new.manage_postback default_validations

# Sends the user scientific benefits of doing gratitude exercises
def explain_benefits pb
	text_reply(pb, "Studies have shown that cultivating thankfulness
	 on a daily basis can improve people's quality of life.")
	text_reply(pb, "Here are some links to different articles and papers, so you
	 can see the results and assess the benefits for yourself.")
	text_reply(pb, 'https://www.health.harvard.edu/newsletter_article/in-praise-of-gratitude')
	text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/12585811')
	text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/20515249')
end

# Intro interaction
def introduction pb
	text_reply(pb, "I'm Mind Fulfilled Bot, a Facebook chatbot
		 designed to try help you feel more content and grateful living your life.")
	button_reply(pb,"Please tap 'Learn more' to learn more about how I work.",
		[{type: 'postback', title: 'Learn more', payload: PAYLOADS[:learn_more]}])
end

# Part of intro sequence
def learn_more pb
	text_reply(pb, "I work by messaging you once per day at night to
	 reflect how you felt and to tell me one thing that you were grateful about that day.")
	text_reply(pb, "Please click on the menu on the bottom of the screen to
	 see more options, such as why what I do can help you be happier.")
	button_reply(pb,"If you are ready to proceed, please tap 'Begin my journey'.",
		[{type: 'postback', title: 'Begin my journey', payload: PAYLOADS[:begin_routine]}])
end

# Routine that asks user to rate their day and logs his grateful message
def begin_routine id
	content = {
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
	send_msg_first id, content
end

# Routine that asks user to rate their day and logs his grateful message
def handle_mood pb
	case pb.payload
	when PAYLOADS[:mood_good]
		@feeling = "Content"
		text_reply(pb, "I'm happy for you :)")
		text_reply(pb, "What's one thing about today that you can be happy about?")
	when PAYLOADS[:mood_okay]
		@feeling = "Okay"
		text_reply(pb, "I'm glad your day wasn't too hard!")
		text_reply(pb, "What's one thing about today that you can be happy about?")
	when PAYLOADS[:mood_bad]
		@feeling = "Discontent"
		text_reply(pb, "That's too bad.. I hope that tomorrow will be a happier day for you.")
		text_reply(pb, "You can always find something to be grateful for – even during the worst moments!")
		text_reply(pb, "What's one thing about today that you can be happy about?")
	end
end

# Confirms user whether he wants to really save his previous message as a log
def handle_user_log msg
	@user_log = msg.text
	button_reply(msg, "Confirm your answer of \"#{@user_log}\"?",
		[{type: 'postback', title: 'Yes', payload: PAYLOADS[:submit_yes]},
		{type: 'postback', title: 'No', payload: PAYLOADS[:submit_no]}])
end

# Accepts user's gratefulness post and asks for confirmation through postback
def confirm_submit pb
	save_log @feeling, @user_log
	text_reply(pb, 'Great to hear.')
	text_reply(pb, "Thanks! I'm glad to be of help to you.")
	text_reply(pb, "Please feel free to interact with me further as specified in the menu.
	 Else, I'll see you tomorrow!")
end

# After executing, returns to postback manager; user can type his/her answer again
def unconfirm_submit pb
	text_reply(pb, "I'd love to hear your response again.")
end

# Sends the user back
def redirect_message pb
	text_reply(pb, "I don't understand what you are trying to do. Please continue where you left off before
	 or interact with the menu.")
end

# Tells the user to type the date message again
def invalid_date msg
	text_reply(msg, "The date you entered isn't properly formatted! Please interact with the menu.")
end

# Ask for formatted date to display logs from a date correctly
def ask_for_formatted_date pb
	text_reply(pb, "Please type the date of interest in the form yyyy-mm-dd.")
end

# Saves the user's string input along with date to the database
def save_log feeling, entry
	DBManager.save_log feeling, entry
end

# Fetches database rows with the specified date and sends a message for each log
def show_logs_from_date id, date
	query = DBManager.user_info.where(date: date)
	entries_array = query.empty? ? {} : DBManager.user_info.where(date: date).all #PS: Is an array of hashes
	if entries_array.size == 0
		send_msg_first id, {text: "You don't have any entries on that date. However, you have entries on the following dates:"}
		date_hash = DBManager.user_info.all
		date_hash.each do |entry|
			send_msg_first id, {text: entry[:date]}
		end
		send_msg_first id, {text: "Feel free to search for another date or interact with the menu."}
	else
		entries_array.each do |entry|
			send_msg_first id, {text: "Date: #{entry[:date]} – You felt: #{entry[:feeling]}"}
			send_msg_first id, {text: "You said: \"#{entry[:user_log]}\""}
		end
		send_msg_first id, {text: "That's it! Feel free to interact with the menu more."}
	end
end

# Fetches the user_log column from the database and sends a message for each log
def show_all_logs id
	entries_array = DBManager.user_info.all
	if entries_array.size == 0
		# reply back 'you have no entries'
		send_msg_first id, {text: "You don't have any entries! Create one by clicking 'I'll tell you about today now.' button from the menu."}
	else
		entries_array.each do |entry|
			send_msg_first id, {text: "Date: #{entry[:date]} – You felt: #{entry[:feeling]}"}
			send_msg_first id, {text: "You said: \"#{entry[:user_log]}\""}
		end
		send_msg_first id, {text: "That's it! Feel free to interact with the menu more."}
	end
end