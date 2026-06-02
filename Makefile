PANDOC ?= pandoc
PDF_ENGINE ?= tectonic

PAPER_MD := paper/qbit-whitepaper.md
METADATA := paper/metadata.yaml
TEMPLATE := paper/template.tex
HTML_CSS := paper/html.css

BUILD_DIR := paper/build
OUTPUT_BASENAME := qbit-whitepaper
OUTPUT_TEX := $(BUILD_DIR)/$(OUTPUT_BASENAME).tex
OUTPUT_PDF := $(BUILD_DIR)/$(OUTPUT_BASENAME).pdf
OUTPUT_HTML := $(BUILD_DIR)/$(OUTPUT_BASENAME).html

SPEC_MD := paper/qbit-consensus-spec.md
SPEC_METADATA := paper/consensus-metadata.yaml
SPEC_OUTPUT_BASENAME := qbit-consensus-spec
SPEC_OUTPUT_TEX := $(BUILD_DIR)/$(SPEC_OUTPUT_BASENAME).tex
SPEC_OUTPUT_PDF := $(BUILD_DIR)/$(SPEC_OUTPUT_BASENAME).pdf
SPEC_OUTPUT_HTML := $(BUILD_DIR)/$(SPEC_OUTPUT_BASENAME).html

TEX_ARTIFACTS := $(OUTPUT_TEX) $(SPEC_OUTPUT_TEX)
PDF_ARTIFACTS := $(OUTPUT_PDF) $(SPEC_OUTPUT_PDF)
HTML_ARTIFACTS := $(OUTPUT_HTML) $(SPEC_OUTPUT_HTML)
ARTIFACTS := $(TEX_ARTIFACTS) $(PDF_ARTIFACTS) $(HTML_ARTIFACTS)

.PHONY: tex pdf html spec-tex spec-pdf spec-html texs pdfs htmls artifacts clean

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

tex: $(OUTPUT_TEX)

$(OUTPUT_TEX): $(PAPER_MD) $(METADATA) $(TEMPLATE) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--to=latex \
		--standalone \
		--resource-path=paper:. \
		--metadata-file=$(METADATA) \
		--template=$(TEMPLATE) \
		--output=$@ \
		$(PAPER_MD)

pdf: $(OUTPUT_PDF)

$(OUTPUT_PDF): $(PAPER_MD) $(METADATA) $(TEMPLATE) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--standalone \
		--resource-path=paper:. \
		--metadata-file=$(METADATA) \
		--template=$(TEMPLATE) \
		--pdf-engine=$(PDF_ENGINE) \
		--output=$@ \
		$(PAPER_MD)

html: $(OUTPUT_HTML)

$(OUTPUT_HTML): $(PAPER_MD) $(METADATA) $(HTML_CSS) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--to=html5 \
		--standalone \
		--section-divs \
		--mathml \
		--embed-resources \
		--resource-path=paper:. \
		--metadata-file=$(METADATA) \
		--css=$(HTML_CSS) \
		--output=$@ \
		$(PAPER_MD)

spec-tex: $(SPEC_OUTPUT_TEX)

$(SPEC_OUTPUT_TEX): $(SPEC_MD) $(SPEC_METADATA) $(TEMPLATE) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--to=latex \
		--standalone \
		--resource-path=paper:. \
		--metadata-file=$(SPEC_METADATA) \
		--template=$(TEMPLATE) \
		--output=$@ \
		$(SPEC_MD)

spec-pdf: $(SPEC_OUTPUT_PDF)

$(SPEC_OUTPUT_PDF): $(SPEC_MD) $(SPEC_METADATA) $(TEMPLATE) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--standalone \
		--resource-path=paper:. \
		--metadata-file=$(SPEC_METADATA) \
		--template=$(TEMPLATE) \
		--pdf-engine=$(PDF_ENGINE) \
		--output=$@ \
		$(SPEC_MD)

spec-html: $(SPEC_OUTPUT_HTML)

$(SPEC_OUTPUT_HTML): $(SPEC_MD) $(SPEC_METADATA) $(HTML_CSS) | $(BUILD_DIR)
	$(PANDOC) \
		--from=markdown+pipe_tables+fenced_code_blocks \
		--to=html5 \
		--standalone \
		--section-divs \
		--toc \
		--toc-depth=3 \
		--mathml \
		--embed-resources \
		--resource-path=paper:. \
		--metadata-file=$(SPEC_METADATA) \
		--css=$(HTML_CSS) \
		--output=$@ \
		$(SPEC_MD)

texs: $(TEX_ARTIFACTS)

pdfs: $(PDF_ARTIFACTS)

htmls: $(HTML_ARTIFACTS)

artifacts: $(ARTIFACTS)

clean:
	rm -rf $(BUILD_DIR)
