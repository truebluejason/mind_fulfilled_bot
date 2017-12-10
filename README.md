# mindfulfilledbot
A Facebook Bot designed to help change the user's viewpoint to one of contentment

TO DEPLOY ON COMPUTER
0. Open two tabs on Terminal, go to the bot folder and run rackup -p 5000 on one and ./ngrok on the other
1. Go to "https://developers.facebook.com/apps/150648382325886/webhooks/"
2. In the callback URL, type ngrok's https address
3. Type in the verify token, AKA secret in app.rb :)
