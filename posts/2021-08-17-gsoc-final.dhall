let C = ../common.dhall
in
	{ date = "2021-08-17"
	, title = "GSoC Final"
	, content = [ C.H.rawText (./2021-08-17-gsoc-final.content.md.html as Text) ]
	}
