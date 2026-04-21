# README

## Introduction

My name is [Derek Anderson](https://github.com/dbanderson1). I am graduate student in Kinesiology at Auburn University. This repository
contains a reproducible pipeline for generating police wellness reports which is also my final project for [PLPA 6820 (Reproducible
Science)](https://bulletin.auburn.edu/coursesofinstruction/plpa/) taught by [Zach Noel](https://agriculture.auburn.edu/about/directory/faculty/zachary-noel/).

## Overview

The scripts found in this project may be beneficial to individuals who are conducting wellness initiatives and work with military, police, fire, or emergency medical services. The overall project is split into two scripts.

### Script #1 - catagorize_data.R

The first script, [catagorize_data.R](https://github.com/dbanderson1/police_fitness/blob/main/categorize_data.R), takes raw fitness data for each participant and places them into ordinal categories. This script is written entirely in base R and requires no additional libraries. The output of this script is later used to generate individual wellness reports. It could also be used to provide summary reports to leadership.

Here you’ll find R script to categorize:

- Body Mass Index (BMI)
- Body Fat Percentages (BF%)
- Sit and Reach
- YMCA Bench Press
- VO2 Max
- Grip Strength
- Vertical Jump
- Forward Lean Balance Test
- Functional Movement Screen (FMS)

The raw data for your script should have the following file structure:
``` r
head(read.csv("input/mock_data.csv"))
```

## File Links

For ease of reference here are links to graded files:

- assignments (a.k.a. ‘coding notes’)
  - [assingment_1](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_001/assignment_001.R)
  - [assingment_2](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_002/assignment_002.R)
  - [assingment_3](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_003/assignment_003.R)
  - [assingment_4.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_004/assignment_004.md),
    [assingment_4.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_004/assignment_004.Rmd)
  - [assingment_5.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_005/assignment_005.md),
    [assingment_5.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_005/assignment_005.Rmd)
  - [assingment_6.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_006/assignment_006.md),
    [assingment_6.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_006/assignment_006.Rmd)
  - [assingment_7.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_007/assignment_007.md),
    [assingment_7.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_007/assignment_007.Rmd)
  - [assingment_8.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_008/assignment_008.md),
    [assingment_8.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/assignments/assignment_008/assignment_008.Rmd)
- coding challenges
  - [coding_challenge_1](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_1/coding_challenge_1.R)
  - [coding_challenge_2](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_2/coding_challenge_2.R)
  - [coding_challenge_3](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_3/coding_challenge_3.R)
  - [coding_challenge_4.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_4/coding_challenge_4.md),
    [coding_challenge_4.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_4/coding_challenge_4.Rmd)
  - [coding_challenge_5.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_5/coding_challenge_5.md),
    [coding_challenge_5.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_5/coding_challenge_5.Rmd)
  - [coding_challenge_6.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_6/coding_challenge_6.md),
    [coding_challenge_6.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_6/coding_challenge_6.Rmd)
  - [coding_challenge_7.md](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_7/coding_challenge_7.md),
    [coding_challenge_7.Rmd](https://github.com/dbanderson1/plpa_6820_assignments/blob/main/coding_challenges/coding_challenge_7/coding_challenge_7.Rmd)

## File Tree

File tree generated using r code and fs():

``` r
fs::dir_tree()
```

``` bash
.
├── assignments             # Folder for assignments aka coding notes
│   ├── assignment_001
│   │   └── assignment_001.R
│   ├── assignment_002
│   │   └── assignment_002.R
│   ├── assignment_003
│   │   └── assignment_003.R
│   ├── assignment_004
│   │   ├── assignment_004.html
│   │   ├── assignment_004.md
│   │   ├── assignment_004.Rmd
│   │   ├── assignment_004_files
│   │   │   └── figure-gfm
│   │   │       └── include figures-1.png
│   │   └── pressure-1.png
│   ├── assignment_005
│   │   ├── assignment_005.html
│   │   ├── assignment_005.md
│   │   ├── assignment_005.Rmd
│   │   └── assignment_005_files
│   │       └── figure-gfm
│   │           ├── unnamed-chunk-11-1.png
│   │           └── unnamed-chunk-16-1.png
│   ├── assignment_006
│   │   ├── assignment_006.html
│   │   ├── assignment_006.md
│   │   ├── assignment_006.Rmd
│   │   └── assignment_006_files
│   │       └── figure-gfm
│   │           └── unnamed-chunk-15-1.png
│   ├── assignment_007
│   │   ├── assignment_007.html
│   │   ├── assignment_007.md
│   │   ├── assignment_007.Rmd
│   │   └── assignment_007_files
│   │       └── figure-gfm
│   │           ├── unnamed-chunk-10-1.png
│   │           ├── unnamed-chunk-13-1.png
│   │           ├── unnamed-chunk-14-1.png
│   │           ├── unnamed-chunk-19-1.png
│   │           ├── unnamed-chunk-2-1.png
│   │           ├── unnamed-chunk-20-1.png
│   │           ├── unnamed-chunk-3-1.png
│   │           ├── unnamed-chunk-7-1.png
│   │           ├── unnamed-chunk-8-1.png
│   │           └── unnamed-chunk-9-1.png
│   └── assignment_008
│       ├── assignment_008.html
│       ├── assignment_008.md
│       ├── assignment_008.Rmd
│       ├── assignment_008_files
│       │   └── figure-gfm
│       │       ├── unnamed-chunk-12-1.png
│       │       ├── unnamed-chunk-13-1.png
│       │       └── unnamed-chunk-13-2.png
│       └── renv.png
├── coding_challenges       # Folder for Coding Challenges
│   ├── coding_challenge_1
│   │   └── coding_challenge_1.R
│   ├── coding_challenge_2
│   │   └── coding_challenge_2.R
│   ├── coding_challenge_3
│   │   └── coding_challenge_3.R
│   ├── coding_challenge_4
│   │   ├── coding_challenge_4.html
│   │   ├── coding_challenge_4.md
│   │   ├── coding_challenge_4.Rmd
│   │   └── coding_challenge_4_files
│   │       └── figure-gfm
│   │           └── Commbine and Display Plots-1.png
│   ├── coding_challenge_5
│   │   ├── coding_challenge_5.html
│   │   ├── coding_challenge_5.md
│   │   ├── coding_challenge_5.Rmd
│   │   └── coding_challenge_5_files
│   │       └── figure-gfm
│   │           └── Plot-1.png
│   ├── coding_challenge_6
│   │   ├── coding_challenge_6.html
│   │   ├── coding_challenge_6.md
│   │   └── coding_challenge_6.Rmd
│   └── coding_challenge_7
│       ├── coding_challenge_7.html
│       ├── coding_challenge_7.md
│       ├── coding_challenge_7.Rmd
│       └── coding_challenge_7_files
│           └── figure-gfm
│               └── unnamed-chunk-6-1.png
├── data_files              # Folder with data files used by scripts
│   ├── anthro.csv
│   ├── BacterialAlpha.csv
│   ├── Bull_richness.csv
│   ├── Cities.csv
│   ├── corr.csv
│   ├── diff_abund.csv
│   ├── DiversityData.csv
│   ├── EC50_all.csv
│   ├── Metadata.csv
│   ├── MycotoxinData.csv
│   ├── PlantEmergence.csv
│   ├── raw_data_valent2023_pythium_seedtreatment.csv
│   ├── TipsR.csv
│   └── weight_loss_data.csv
├── plpa_6820_assignments.Rproj # Top level R Project
├── README.html
├── README.md               # Top level directory README
├── README.Rmd
└── renv # This is the top level RENV which controls versions required to ensure the script populates the same results
```

## How to Use

Feel free to browse and copy the code if you are also just learning R
and Rmarkdown.

### Clone this repository:

``` bash
git clone https://github.com/dbanderson1/plpa_6820_assignments.git
```
