# STAMP v2.0
### Spatial Transcript Abundance Mapping Pipeline

STAMP v2.0 is a MATLAB script for generating spatial maps of mean HCR RNA FISH image intensity and intensity profiles. Version 2.0 is adapted for analyzing images of the developing chick retina.

## What the script does

The script takes one TIFF image of the developing retina and its corresponding mask, calculates mean intensity in spatial blocks, and creates normalized intensity maps and 1-D intensity profiles along the TN (x-axis; Temporal–Nasal) and DV (y-axis; Dorsal–Ventral) axes. It saves figures and profile data in an `Analyzed` folder.

The user selects the center of the high-acuity area (HAA) on the image to define the coordinate origin, `(0, 0)`. The TN and DV intensity profiles are plotted as distances relative to this point.

## Inputs

- An aligned TIFF image of the retina, with the DV axis along the image's y-axis and the TN axis along its x-axis.
- A corresponding TIFF mask with the same dimensions as the image.
- Pixel size in micrometers, set in the script.
- Block size in pixels, set in the script.

The script prompts you to select the image and mask.

## Outputs

The script creates an `Analyzed` folder containing:

- Normalized intensity maps.
- Directional image strips and intensity-profile plots.
- An Excel workbook containing the profile measurements.
- `origin_coords.mat`, which stores the selected origin coordinates.

On a later run, the script offers to reuse the saved origin or select a new one. Make sure the saved origin corresponds to the image being analyzed; select a new origin when needed.

## Requirements

- MATLAB.
- MATLAB functions or toolboxes needed for image processing and figure export.
- The colormap functions used by the script: `viridis`, `plasma`, `cbrewer2`, `fake_parula`, and `magma`.

## Important notes

- Check that the image and mask have matching dimensions.
- Set the pixel size and block size to match your experiment.
- The script currently processes one image and mask at a time.
- The current script does not import TrackMate results or perform spot counting.

## How to run

1. Open `STAMP_v2_0.m` in MATLAB.
2. Set the pixel size and block size, if needed.
3. Run the script.
4. Select the TIFF image and its corresponding mask when prompted.
5. Select the HAA center on the image to define the `(0, 0)` origin, or choose to reuse a previously saved origin when prompted.

## Citation

If STAMP v2.0 contributes to your research, analysis, or figures, please
acknowledge the pipeline and cite the associated manuscript.

Joisher HNV, Lee C, Prabhakara C, van der Weide I, Si Y, Lonfat N, Cepko C. *Integration of in situ hybridization and scRNA-seq data provides a 2D topographical map of the developing retina across species.* bioRxiv (2026). doi: 10.64898/2026.01.04.697548.