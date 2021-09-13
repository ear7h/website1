let C = ../common.dhall
in
	{ date = "2021-06-07"
	, title = "Slack vs. Discord"
	, content = [ C.H.rawText (./2021-06-07-slack-vs-discord.content.html as Text) ]
	}
