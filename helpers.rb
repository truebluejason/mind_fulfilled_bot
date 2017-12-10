require 'byebug'
require 'facebook/messenger'
include Facebook::Messenger

module EasyAPI

	# Takes in object, text
	def text_reply object, msg
		object.mark_seen
		sleep 1
		msg = msg.gsub!(/[\n]*[\t]*/, "")
		object.reply(text: msg)
	end

	# Takes in object, link to image
	def image_reply object, link
		object.mark_seen
		sleep 1
		object.reply(
			attachment: {
				type: 'image',
				payload: {
					url: link
				}
			}
		)
	end

	# Takes in user id and hash for message content and delivers the message
	def send_msg_first id, msg
		sleep 1
		message_options = {
			recipient: {id: id},
			message: msg
		}
		Bot.deliver(message_options, access_token: ENV['ACCESS_TOKEN'])
	end

	# Takes in object, text, and array of buttons
	def button_reply object, msg, buttons
		object.mark_seen
		sleep 1
		object.reply(
			attachment: {
				type: 'template',
				payload: {
					template_type: 'button',
					text: msg,
					buttons: buttons
				}
			}
		)
	end

	# Randomly chooses response to send from a pool
	def random_response pool

	end
end