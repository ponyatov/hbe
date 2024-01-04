# var
MODULE  = $(notdir $(CURDIR))
NOW     = $(shell date +%d%m%y)
REL     = $(shell git rev-parse --short=4 HEAD)
BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
CORES  ?= $(shell grep processor /proc/cpuinfo | wc -l)

# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
DOC = $(CWD)/doc
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ  = $(HOME)/gz

# tool
CURL = curl -L -o
DC   = dmd
BLD  = dub build --compiler=$(DC)
RUN  = dub run   --compiler=$(DC)

# src
D += $(wildcard src/*.d)

# all
.PHONY: all run
all: bin/$(MODULE)
run: $(D) $(J) $(T)
	$(RUN)

# format
.PHONY: format
format: tmp/format_d
tmp/format_d: $(D)
	$(RUN) dfmt -- -i $? && touch $@

# rule
bin/$(MODULE): $(D) $(J) $(T) Makefile
	$(BLD)

# doc
.PHONY: doc
doc: doc/yazyk_programmirovaniya_d.pdf doc/Programming_in_D.pdf \
     doc/Bluebook.pdf

doc/Bluebook.pdf:
	$(CURL) $@ http://stephane.ducasse.free.fr/FreeBooks/BlueBook/Bluebook.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf
doc/Programming_in_D.pdf:
	$(CURL) $@ http://ddili.org/ders/d.en/Programming_in_D.pdf

# install
.PHONY: install update doc gz
install: doc gz
	$(MAKE) update
	dub fetch dfmt
update:
	sudo apt update
	sudo apt install -uy `cat apt.txt`

gz: ref

.PHONY: ref
ref: ref/strongtalk/vm/oops/klass.hpp ref/dbanay/README.md
ref/strongtalk/vm/oops/klass.hpp: $(GZ)/StrongtalkV2.zip
	unzip -d ref $< && touch $@
ref/dbanay/README.md:
	git clone -o gh --depth 1 https://github.com/dbanay/Smalltalk.git ref/dbanay

$(GZ)/StrongtalkV2.zip:
	$(CURL) $@ https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/strongtalk/source-archive.zip

# merge
MERGE += Makefile README.md LICENSE apt.txt $(D)
MERGE += .clang-format .editorconfig .gitattributes .gitignore .stignore
MERGE += bin doc lib inc src tmp

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
#	$(MAKE) doxy ; git add -f docs

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
