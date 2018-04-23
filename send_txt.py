from twilio.rest import Client

# free twilio.com account is Kevin (Ch28!93esCh28!93es)

# Your Account Sid and Auth Token from twilio.com/user/account
account_sid = "AC08057e0f0e127e31ab65e565e59ed3c6"
auth_token = "f6c0f7f58ffcc47038cb4c021aba12fb"
client = Client(account_sid, auth_token)
message = client.messages.create(
	to = "+13219171025",	# phone number
	from_ = "+13215045390",	# twilio number
        body = "I could torture someone with this!") # message
print(message.sid)
