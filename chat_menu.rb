require 'facebook/messenger'
require_relative 'bot'

class ChatMenu

	def self.enable
		# Menu Setup
		Facebook::Messenger::Profile.set({
		  	persistent_menu: [{
		      	locale: 'default',
		      	composer_input_disabled: false,
		      	call_to_actions: [
		      		{
		            	type: 'nested',
		              	title: 'Show me my past responses!',
		              	call_to_actions: [
		              		{
		              			type: 'postback',
		              			title: 'A specific response.',
		              			payload: PAYLOADS[:menu_show_specific]
		              		},
		              		{
		              			type: 'postback',
		              			title: 'All responses.',
		              			payload: PAYLOADS[:menu_show_all]
		              		}
		              	]
		            },
	            	{
	            		type: 'postback',
	              		title: 'How do exactly do you help me?',
	              		payload: PAYLOADS[:menu_reason]
	            	},
		            {
		              	type: 'postback',
		              	title: "I'll tell you about today now.",
		              	payload: PAYLOADS[:menu_act]
		            }
		      	]
	    	}]
		}, access_token: ENV['ACCESS_TOKEN'])
	end
end