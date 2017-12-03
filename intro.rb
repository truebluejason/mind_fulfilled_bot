class Intro

  def self.enable
    # Set call to action button when user is about to address bot for the first time.
    Facebook::Messenger::Profile.set({
      get_started: {
        payload: PAYLOADS[:start]
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end