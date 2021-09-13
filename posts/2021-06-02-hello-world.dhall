let C = ../common.dhall
let XML = C.XML
let H = C.H
let meta =
  { date = "2021-06-02"
  , title = "Hello World"
  }

let p = \(t : Text) -> H.p H.noattr [ H.text t ]
let content =
	[ p ''
		So, as a homework assignment I have to create a website so, I've
		finally taken the time to make it!
		''
	, p ''
		To start things out, I'm just gonna list some topics that I should
		write posts about:
		''
	, H.ul H.noattr
		[ H.li H.noattr [ H.text "Monads and error handling" ]
		, H.li H.noattr [ H.text "Shader math" ]
		, H.li H.noattr
			[ H.text "Computer education"
			, H.ul H.noattr
				[ H.li H.noattr [ H.text "Computers from the middle out" ] ]
			]
		, H.li H.noattr [ H.text "A Haskell tutorial" ]
		]
	]

in meta /\ { content = content }

