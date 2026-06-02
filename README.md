# Qbit White Paper

Qbit is a proposed proof-of-work UTXO network designed around quantum-resistant
spend authorization from block zero.

This repository contains the Qbit white paper and supporting technical
specification. The white paper is a point-in-time artifact: it reflects what we
currently believe Qbit should be, and it is published so the community can
inspect, question, and challenge the design.

The objective is adversarial discussion, not promotion.

## Join the discussion

We invite questions, challenges, and technical feedback through GitHub Issues and
Discussions.

Open an issue for feedback tied to a specific section, claim, assumption, or
design decision. When possible, include the relevant section, page, line, or quote
you are responding to.

Useful comments include:

- Why does this assumption hold?
- What breaks if this condition is false?
- Is this relying on social consensus?
- What prior art supports this?
- Is this claim underspecified?
- This seems to imply X. Is that intended?

Use Discussions for broader questions, design debates, and topics that do not map
cleanly to a specific line or section.

## Release focus

Qbit treats post-quantum security as a base-layer condition. The white paper
explains how a Bitcoin-like proof-of-work UTXO network changes
when quantum-resistant spend authorization is native from genesis. The consensus
specification translates that design into implementation-facing rules.

## What to evaluate

Readers should pay particular attention to the following design choices:

- Qbit is a new chain with its own genesis block, asset, monetary policy, and
  consensus rules. It is not a hard fork or continuation of another existing blockchain.
- Spend authorization uses bounded `SLH-DSA-SHA2-128s-bounded30` signatures in
  the active spend path.
- P2MR outputs commit to a Merkle root so public keys and unused script branches
  stay hidden until spend time.
- Witness accounting uses `WITNESS_SCALE_FACTOR = 1`, so large post-quantum
  witnesses are priced by their actual byte cost.
- Blocks use a 2,000,000-byte / 2,000,000-weight envelope designed around
  propagation, validation, storage, and fee pressure under post-quantum
  signatures.
- Qbit uses one most-work chain fed by two SHA-256 mining lanes: permissionless
  native mining and AuxPoW-backed merge mining.
- Issuance is deterministic, with a 210,000,000 QBT consensus cap and no
  inherited legacy balance migration.
- Long-term node operation modes are explicit, including full witness retention
  and optional witness pruning.

## Intended audience

These documents are written for implementers, auditors, wallet authors,
exchanges, custodians, miners, node operators, and technically literate readers
who want to understand the design tradeoffs behind Qbit.

The current white paper should not be read as a final protocol specification.
It is a public review artifact intended to surface weak assumptions, missing
prior art, unclear claims, and design risks.

## Repository layout

- `paper/qbit-whitepaper.md`: canonical white paper source
- `paper/qbit-consensus-spec.md`: consensus specification source for
  implementers and operators
- `paper/metadata.yaml`: Pandoc metadata used for rendering
- `paper/consensus-metadata.yaml`: Pandoc metadata used for rendering the consensus spec
- `paper/template.tex`: whitepaper-style LaTeX template
- `paper/html.css`: stylesheet embedded into generated HTML artifacts
- `paper/build/`: generated `.tex`, `.pdf`, and `.html` artifacts

## Prerequisites

- `pandoc`
- `tectonic` for the default PDF build, or `xelatex` if you prefer a different engine

## Build

```sh
make artifacts
make tex
make pdf
make html
make spec-tex
make spec-pdf
make spec-html
make clean
```

`make artifacts` writes all generated `.tex`, `.pdf`, and `.html` outputs to `paper/build/`.

`make tex` writes `paper/build/qbit-whitepaper.tex`.

`make pdf` writes `paper/build/qbit-whitepaper.pdf`.

`make html` writes `paper/build/qbit-whitepaper.html`.

`make spec-tex` writes `paper/build/qbit-consensus-spec.tex`.

`make spec-pdf` writes `paper/build/qbit-consensus-spec.pdf`.

`make spec-html` writes `paper/build/qbit-consensus-spec.html`.

To use XeLaTeX instead of Tectonic:

```sh
make artifacts PDF_ENGINE=xelatex
make pdf PDF_ENGINE=xelatex
make spec-pdf PDF_ENGINE=xelatex
```

## Notes

- Markdown is the canonical source; generated LaTeX, PDF, and HTML files are
  build outputs.
- The white paper is the narrative design document. The consensus specification
  is the implementation-facing reference for consensus rules, launch-profile
  parameters, wallet/signing behavior, and node policy defaults.
