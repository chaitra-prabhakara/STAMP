# STAMP
### Spatial Transcript Abundance Mapping Pipeline

STAMP is a collection of MATLAB scripts for spatial analysis of in situ hybridization data. The repository contains different pipeline versions developed for use with separate studies.

## Versions

- **[STAMP v1.0](v1.0/README.md)** — Pipeline for mapping PITX2 transcript density in developing chick foregut. Includes instructions and manuscript details for version 1.0.
- **[STAMP v2.0](v2.0/README.md)** — Pipeline for mapping mean RNA FISH intensity of various HCR probes in developing chick retina. Includes instructions, example data, example outputs and manuscript details for version 2.0.

## Getting started

Open the README in the folder for the version you want to use. Each version’s README describes its requirements, inputs, outputs, instructions, and associated manuscript.

## Repository structure

```text
STAMP/
├── README.md
├── CITATION.cff
├── LICENSE.md
├── .gitattributes
├── .gitignore
├── v1.0/
│   └── [version 1.0 files]
└── v2.0/
    ├── README.md
    ├── STAMP_v2_0.m
    ├── Example/
    │   ├── [example image and mask]
    │   └── Analyzed/
    │       └── [example outputs]
    └── third_party/
        ├── README.md
        ├── cbrewer2/
        ├── perceptually_uniform_colormaps/
        └── [COLORSPACE files]
```