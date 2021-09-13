ROOT ?= $(CURDIR)
export ROOT

# TODO: generate post list using patsubst
ALL= \
	posts/2021-08-17-gsoc-final.html \
	posts/2021-06-07-slack-vs-discord.html \
	posts/2021-06-07-algebra.html \
	posts/2021-06-02-hello-world.html \
	posts.html \
	index.html \
	projects.html \
	graphics.html \
	me.html

DHALL=dhall $(DHALL_FLAGS)

.PHONY: all
all: $(ALL)

posts/%.html: posts/%.dhall posts/%.md common.dhall
	pandoc -f gfm -t html posts/$*.md > posts/$*.content.md.html
	echo "(./common.dhall).renderPost (./$<)" | $(DHALL) text --explain > $@

posts/%.html: posts/%.dhall posts/%.content.html common.dhall
	echo "(./common.dhall).renderPost (./$<)" | $(DHALL) text --explain > $@

%.html: %.dhall common.dhall
	$(DHALL) text --file $< > $@

.PHONY: clean
clean:
	rm -rf build
	find . -name "*.html" ! -name "*.content.html" -exec rm -- "{}" +

