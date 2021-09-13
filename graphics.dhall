let C = ./common.dhall
let Prelude = C.Prelude
let XML = C.XML
let List/map = Prelude.List.map
let List/concat = Prelude.List.concat
let Text/lowerASCII = Prelude.Text.lowerASCII
let H = C.H
let mkDoc = C.mkDoc
let ahref = C.ahref
let root = C.root

let Image =
	< Iframe : Text
	| Img : Text
	>

let Graphic =
	{ name : Text
	, image : Image
	, description : List XML
	}

let graphicList =
	[
		{ name = "Glowglobe"
		, image =
			Image.Iframe "https://www.shadertoy.com/embed/fdX3RN?gui=true&t=10&paused=true&muted=false"
		, description =
			[ H.text ''
				This was pretty pretty fun to make, taking several steps of
				data transformation. First, I got the coastlines from the ''
			, ahref
				"https://www.naturalearthdata.com/"
				"Natural Earth dataset"
			, H.text " that I had sitting around in my computer "
			, ahref
				"https://github.com/go-spatial/tegola-osm/blob/master/natural_earth.sh"
				"from another project"
			, H.text ''
				. Then, I made a program to simplify the geometries and
				write them out as an array in glsl syntax. The math involved
				is relatively simple, first the lat/long, (spherical)
				cordinates need to be turned into rectangular coordinates.
				The geometries are just made up of line segments and to draw
				them on the screen, color is assigned to the pixel if it is
				sufficiently close to the line.''
			]
		}
	,
		{ name = "Fuzzy Box"
		, image =
			Image.Iframe "https://www.shadertoy.com/embed/wtGBRK?gui=true&t=10&paused=true&muted=false"
		, description =
			[ H.text ''
				My first attempt at writing a shader with SDFs and
				raymarching. It uses simple primitives, the sphere and cube,
				combined using a union operation. As an added touch, I also
				attempted to recreate depth of field by deflecting the
				camera rays randomly as it marches, inspired by the ''
			, ahref
				"#graph"
				"gif below"
			, H.text ''
				. The intensity and focus distance can be changed by
				clicking and draging the mouse around.''
			]
		}
	,
		{ name = "Graph"
		, image =
			Image.Img "${root}/graph.gif"
		, description =
			[ H.text ''
				My first successful attempt at any sort of rendering. It
				was a inneficient and mediocre implementation of this ''
			, ahref
				"https://inconvergent.net/2019/depth-of-field/"
				"depth of field algorithm"
			, H.text "."
			]
		}
	]

let mkImage = \(img : Image) -> merge
	{ Iframe = \(src : Text) ->
		H.iframe (toMap
			{ width = "400"
			, height = "300"
			, frameborder = "0"
			, allowfullscreen = ""
			, src
			}) [ H.text " "]
	, Img = \(src : Text) ->
		H.img (toMap
			{ width = "400"
			, height = "300"
			, src
			})
	} img

let linkFormat = \(s : Text) -> Text/replace " " "-" (Text/lowerASCII s)

let mkGraphic = \(g : Graphic) ->
	[ H.h2 H.noattr
		[ H.a (toMap
		  { id = linkFormat g.name
		  , href = "#${linkFormat g.name}"
		  })
		  [ H.text "#" ]
		, H.text " ${g.name}"
		]
	, mkImage g.image
	, H.p H.noattr g.description
	]

let heading = H.h1 H.noattr [ H.text "graphics" ]
let body = List/concat XML
  (List/map Graphic (List XML) mkGraphic graphicList)

in mkDoc "~julio/graphics.html" ( [ heading ] # body )
