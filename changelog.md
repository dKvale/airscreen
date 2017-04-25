# Change Log
Notable changes to this project are documented in this file.

## [Unreleased]
### Added
- Toxicity values for EPA Region 5 states

### Changed
- MPSFs for Lead and Lead compounds updated to align with IRAP modeling results. This corrects for the high default value assigned to the _Henry's Law constant_ for inorganic metals.
- All inhalation health benchmarks rounded to 2 significant digits
- All of MDH's HRV and HBV chronic inhalation health benchmarks rounded to 1 significant digit, except for benzene
- Tetrachloroethylene (Perchloroethylene) non-cancer IHB updated from 100 to 15 ug/m3 per MDH guidance dated (July 2014)
- Napthalene cancer IHB set to 9 ug/m3 per MDH guidance dated (Feb. 2017)
- Ethylene Oxide cancer IHB set to EPA's IRIS value (Feb. 2017)
- Trimethylbenzenes non-cancer IHB set to EPA's IRIS value (Sept. 2016)
- Ethanol specific risk values identified in references, rather than on separate rows
- Chromic acid mists and dissolved Cr(VI) aerosols CAS# changed to _18540-29-9-aer_

### Fixed
- Benzo(k)fluoranthene CAS# changed to _207-08-9_  
- Furfural CAS# changed to _98-01-1_  
- Formic Acid (ethanol facility) CAS# changed to _64-18-6_
- Ethylene dibromide (Dibromoethane) changed to _Ethylene dibromide (1,2-Dibromoethane)_
- Methylene Bromide CAS# 74-95-3 changed to _Dibromomethane (Methylene Bromide) CAS# 74-95-3_

## 0.0.1  ::  2016-02-09
### Added
- R Shiny project to GitHub
