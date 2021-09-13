let C = ../common.dhall
in
	{ date = "2021-06-07"
	, title = "Algebra"
	, content = [ C.H.rawText (./2021-06-07-algebra.content.html as Text) ]
	}
