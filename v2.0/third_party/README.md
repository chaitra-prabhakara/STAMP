# Third-party software and acknowledgments

STAMP v2.0 includes third-party MATLAB software for generating colormaps.
These components are separate from the STAMP code and are subject to their
respective license and attribution terms. The original license and notice
files are retained with the corresponding software.

## Perceptually Uniform Colormaps for MATLAB

- **MATLAB implementation:** Ander Biguri
- **Original colormap authors:** Stéfan van der Walt and Nathaniel Smith
- **Colormaps used by STAMP:** `viridis`, `plasma`, and `magma`
- **Source:** MATLAB Central File Exchange, *Perceptually uniform colormaps*
- **License:** See the original license file in this package's folder.

The original colormap data is identified by the package author as released
under CC0. The MATLAB implementation is distributed under the license
included with the downloaded package. Retain that license with the files.

## cbrewer2 and ColorBrewer palettes

- **MATLAB implementation:** Scott Lowe
- **ColorBrewer palette creator:** Cynthia Brewer
- **Palette used by STAMP:** `PRGn`
- **Source:** MATLAB Central File Exchange, *cbrewer2*
- **License:** Apache License 2.0, with additional ColorBrewer attribution
  and use conditions described in the original `LICENSE` and `NOTICE` files.

ColorBrewer acknowledgment:

> This product includes color specifications and designs developed by
> Cynthia Brewer (http://colorbrewer.org/).

The original `cbrewer2` `LICENSE` and `NOTICE` files are retained with the
package. Please consult them for the complete terms.

## COLORSPACE

- **Author:** Pascal Getreuer
- **Copyright:** 2005–2010
- **Purpose:** Provides color-space transformations used by `cbrewer2`
  for its default CIELAB interpolation.
- **License:** BSD 2-Clause-style license. The original license text is
  included in the COLORSPACE package folder.

The COLORSPACE license requires retaining its copyright notice, conditions,
and disclaimer when redistributing its source. See the included license
file for the complete terms.

## Package contents and license files

Each third-party package is kept in its own folder with its original
source files and license/notice files. These third-party licenses apply
to their respective components; they do not specify the license for the
STAMP code.

```text
third_party/
├── README.md
├── perceptually_uniform_colormaps/
│   ├── [colormap files]
│   └── [original license file]
├── cbrewer2/
│   ├── [cbrewer2 files, including required data files]
│   ├── LICENSE
│   └── NOTICE
└── colorspace/
    ├── [COLORSPACE files]
    └── LICENSE