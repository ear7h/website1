-- let Prelude = https://prelude.dhall-lang.org/package.dhall
let C = ./common.dhall
let Prelude = C.Prelude
let XML = C.XML
let H = C.H
let List/map = Prelude.List.map
let List/concat = Prelude.List.concat
let Optional/toList = Prelude.Optional.toList
let mkDoc = C.mkDoc
let ahref = C.ahref
let ahrefL = C.ahrefL


let Quote =
	{ Type =
		{ quote : List Text -- list for stanzas
		, work : Text
		, workLink : Optional Text
		, artist : Optional Text
		}
	, default =
		{ workLink = None Text
		, artist = None Text
		}
	}

let unlinesXML = \(lines : List Text) ->
	let f = \(line : Text) ->
		[ H.text line
		, H.br H.noattr
		]
	in List/concat XML (List/map Text (List XML) f lines)

let mkQuote = \(q : Quote.Type) -> H.figure H.noattr
		[ H.blockquote H.noattr (unlinesXML q.quote)
		, H.figcaption H.noattr
			(
				[ H.cite H.noattr
					[ merge
						{ None = H.text q.work
						, Some = (\(link : Text) -> ahref link q.work)
						}
						q.workLink
					]
				]
			# (List/map Text XML
				(\(t : Text) -> H.text " ${t}")
				(Optional/toList Text q.artist))
			)
		]
let quotes =
	[ Quote::
		{ quote = [ "A strange game; the only winning move is not to play" ]
		, work = "WarGames"
		, workLink = Some "https://en.wikipedia.org/wiki/WarGames"
		}
	, Quote::
		{ quote = [ "What's up" ]
		, work = "A Night at the Roxbury"
		, workLink = Some "https://en.wikipedia.org/wiki/A_Night_at_the_Roxbury"
		}
	, Quote::
		{ quote =
			[ "That old sayin' them that's got are them that gets"
			, "Is somethin' I can't see"
			, "If ya gotta have somethin'"
			, "Before you can get somethin'"
			, "How do ya get your first is still a mystery to me"
			]
		, work = "Them That Got"
		, artist = Some "by Ray Charles"
		}
	, Quote::
		{ quote =
			[ "The man that knows something knows that he knows nothing at all" ]
		, work = "On & On"
		, artist = Some "by Eriykah Badu"
		}
	] : List Quote.Type

let cowSayWords  = "BLM, trans rights, free Palestine"
let cowSayText = ''
 ___________________________________
< BLM, trans rights, free Palestine >
 -----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
''

let cowSay = H.pre (toMap
	{ aria-label = "cowsay ${cowSayWords}"
	, title = "cowsay ${cowSayWords}"
	})
	[ H.text cowSayText ]

in mkDoc "~julio"
	[ H.h1 H.noattr [ H.text "~julio's internet home page" ]
	, H.p H.noattr [ H.text "My name is Julio (he/him)" ]
	, H.ul H.noattr
		[ H.li H.noattr
			[ H.text "I start a lot of "
			, ahrefL "projects.html" "projects"
			, H.text " that I don't finish"
			]
		, H.li H.noattr
			[ H.text "Sometimes I "
			, ahrefL "posts.html" "write"
			]
		, H.li H.noattr
			[ H.text "I dable in "
			, ahrefL "graphics.html" "graphics"
			]
		, H.li H.noattr
			[ ahrefL "me.html" "And more" ]
		]
	, H.h2 H.noattr [ H.text "Misc" ]
	, H.ul H.noattr
		[ H.li H.noattr
			[ ahrefL "quine.go" "quine.go"
			, H.text " - a self reproducing program"
			]
		]
	, H.h2 H.noattr [ H.text "Quotes" ]
	, H.ul H.noattr
		(List/map Quote.Type XML
			(\(q : Quote.Type) -> H.li H.noattr [ mkQuote q ])
			quotes)
	, H.figure H.noattr [ cowSay ]
	]


