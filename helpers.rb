require 'byebug'
require 'facebook/messenger'
include Facebook::Messenger

module EasyAPI

	# Takes in object, text
	def text_reply object, msg
		msg = msg.gsub!(/[\n]*[\t]*/, "")
		object.reply(text: msg)
	end

	def image_reply object, link
		object.reply(
			attachment: {
				type: 'image',
				payload: {
					url: link
				}
			}
		)
	end

	# Takes in object, text, and array of buttons
	def button_reply object, msg, buttons
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