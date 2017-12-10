require 'byebug'
require 'facebook/messenger'
require_relative 'bot'
include Facebook::Messenger

class PostbackManager

	def manage_postback validations
		Bot.on :postback do |pb|
			payload = pb.payload
			if validations.include? payload
				handle_payload pb, payload, validations
			else
				redirect_message pb
				manage_postback validations
			end
		end
	end

	def manage_answer_message validations
		Bot.on :message do |msg|
			puts "Got an answer message: #{msg.text}!"
			handle_user_log msg
			manage_postback validations
		end
	end

	def manage_date_message validations
		Bot.on :message do |msg|
			puts "Got a date message: #{msg.text}!"
			begin
				date = Date.parse(msg.text).to_s
				puts "Date received – is #{date}"
				show_logs_from_date @user_id, date
				manage_postback validations
			rescue
				invalid_date msg
				manage_postback validations
			end
		end
	end

	def handle_payload pb, payload, validations
		@user_id = pb.sender['id']
		pb.mark_seen
		case payload
		when PAYLOADS[:menu_reason]
			validations = default_validations
			explain_benefits pb
			manage_postback validations
		when PAYLOADS[:menu_act]
			validations = default_validations
			begin_routine @user_id
			validations << PAYLOADS[:mood_good]
			validations << PAYLOADS[:mood_okay]
			validations << PAYLOADS[:mood_bad]
			manage_postback validations
		when PAYLOADS[:menu_show_specific]
			# TO BE IMPLEMENTED
			ask_for_formatted_date pb
			validations = default_validations
			manage_date_message validations
		when PAYLOADS[:menu_show_all]
			show_all_logs @user_id
			validations = default_validations
			manage_postback validations
		when PAYLOADS[:start]
			introduction pb
			validations.delete PAYLOADS[:start]
			validations << PAYLOADS[:learn_more]
			manage_postback validations
		when PAYLOADS[:learn_more]
			learn_more pb
			validations.delete PAYLOADS[:learn_more]
			validations << PAYLOADS[:begin_routine]
			manage_postback validations
		when PAYLOADS[:begin_routine]
			begin_routine @user_id
			validations.delete PAYLOADS[:begin_routine]
			validations << PAYLOADS[:mood_good]
			validations << PAYLOADS[:mood_okay]
			validations << PAYLOADS[:mood_bad]
			manage_postback validations
		when PAYLOADS[:mood_good]
			handle_mood pb
			validations.delete PAYLOADS[:mood_good]
			validations.delete PAYLOADS[:mood_okay]
			validations.delete PAYLOADS[:mood_bad]
			validations << PAYLOADS[:submit_yes]
			validations << PAYLOADS[:submit_no]
			manage_answer_message validations
		when PAYLOADS[:mood_okay]
			handle_mood pb
			validations.delete PAYLOADS[:mood_good]
			validations.delete PAYLOADS[:mood_okay]
			validations.delete PAYLOADS[:mood_bad]
			validations << PAYLOADS[:submit_yes]
			validations << PAYLOADS[:submit_no]
			manage_answer_message validations
		when PAYLOADS[:mood_bad]
			handle_mood pb
			validations.delete PAYLOADS[:mood_good]
			validations.delete PAYLOADS[:mood_okay]
			validations.delete PAYLOADS[:mood_bad]
			validations << PAYLOADS[:submit_yes]
			validations << PAYLOADS[:submit_no]
			manage_answer_message validations
		when PAYLOADS[:submit_yes]
			confirm_submit pb
			validations.delete PAYLOADS[:submit_yes]
			validations.delete PAYLOADS[:submit_no]
			manage_postback validations
		when PAYLOADS[:submit_no]
			unconfirm_submit pb
			manage_answer_message validations
		end
	end
end