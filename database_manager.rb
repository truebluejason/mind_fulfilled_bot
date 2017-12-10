require 'sequel'

class DBManager

	def self.create_user_table
		if !DB.table_exists? :user_info
			DB.create_table :user_info do
	        	primary_key :id
	        	String :date
	        	String :feeling
	        	String :user_log
			end
		end
		@@user_info = DB[:user_info]
	end

	def self.user_info
		@@user_info
	end

	def self.save_log feeling, entry
		@@user_info.insert(date: Date.today.to_s, feeling: feeling, user_log: entry)
	end
end