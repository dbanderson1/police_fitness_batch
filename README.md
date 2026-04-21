# README

## Introduction

My name is [Derek Anderson](https://github.com/dbanderson1). I am
graduate student in Kinesiology at Auburn University. This repository
contains a reproducible pipeline for generating police wellness reports
which is also my final project for [PLPA 6820 (Reproducible
Science)](https://bulletin.auburn.edu/coursesofinstruction/plpa/) taught
by [Zach
Noel](https://agriculture.auburn.edu/about/directory/faculty/zachary-noel/).

## Overview

The scripts found in this project may be beneficial to individuals who
are conducting wellness initiatives and work with military, police,
fire, or emergency medical services. The overall project is split into
two scripts.

### Script \#1 - catagorize_data.R

The first script,
[catagorize_data.R](https://github.com/dbanderson1/police_fitness/blob/main/categorize_data.R),
takes raw fitness data for each participant and places them into ordinal
categories. This script is written entirely in base R and requires no
additional libraries. The output of this script is later used to
generate individual wellness reports. It could also be used to provide
summary reports to leadership.

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

The raw data for your script should be placed in the /input folder. I
should have the following file structure:

``` r
head(read.csv("input/mock_data.csv"))
```

    ##   Participant_num Sex Age height_in height_cm weight_lbs weight_kg  BMI
    ## 1         PFS_001   0  40      65.2     165.6      147.5      66.9 24.4
    ## 2         PFS_002   0  27      69.8     177.3      190.2      86.3 27.5
    ## 3         PFS_003   0  38      72.0     182.9      186.3      84.5 25.3
    ## 4         PFS_004   0  45      69.9     177.5      208.2      94.4 30.0
    ## 5         PFS_005   0  36      68.0     172.7      179.5      81.4 27.3
    ## 6         PFS_006   0  39      67.4     171.2      160.6      72.8 24.8
    ##   BMD_g_cm2 BMD_perc BMC_lbs Body_Fat_perc total_mass_lbs lean_muscle_mass_perc
    ## 1     1.188       61     6.3          13.7          148.0                  86.3
    ## 2     0.979       72     7.4          21.6          193.1                  78.4
    ## 3     1.600       66     6.5          18.3          188.2                  81.7
    ## 4     1.598       76     6.2          20.9          213.1                  79.1
    ## 5     1.394       46     8.1          18.5          179.4                  81.5
    ## 6     1.148       76     5.9          21.1          161.2                  78.9
    ##   lean_muscle_mass_lbs fat_mass_lbs RMR_cal_d CV_test HR_resting_seated
    ## 1                127.7         20.3      1488       0                70
    ## 2                151.4         41.7      1801       0                63
    ## 3                153.8         34.4      1827       0                72
    ## 4                168.6         44.5      1771       0                62
    ## 5                146.2         33.2      1790       0                74
    ## 6                127.2         34.0      1597       0                75
    ##   time_total_mmss HR_max_test HR_85perc_max VO2_max_est dom_hand grip_max_L_lbs
    ## 1            9:57         172         146.2       51.46        0          120.5
    ## 2            8:15         189         160.6       41.06        0           78.1
    ## 3            7:15         179         152.2       37.15        0           85.2
    ## 4            8:27         183         155.5       37.32        1           62.8
    ## 5            8:10         191         162.4       40.82        0          109.9
    ## 6            6:09         188         159.8       29.15        1           99.7
    ##   grip_max_R_lbs grip_max_sum_lbs vertical_jump_in bench_press_reps plank_mmss
    ## 1          128.1            248.6             28.3               22       3:14
    ## 2           78.6            156.7             16.7               25       1:04
    ## 3           93.1            178.3             15.0               14       1:42
    ## 4           72.4            135.2             10.2               14       1:12
    ## 5          121.4            231.3             24.1               29       2:23
    ## 6           96.1            195.8              8.4                6       0:15
    ##   sit_reach_in functional_reach_in fms_pain_L_scap fms_pain_R_scap
    ## 1        14.44               16.70               0               0
    ## 2        15.60               17.68               0               0
    ## 3        14.63               14.74               0               0
    ## 4        18.08               14.58               0               0
    ## 5        24.01               16.60               0               0
    ## 6        11.71               16.94               1               0
    ##   fms_pain_press_prone fms_pain_posterior_rock fms_modified_pushup
    ## 1                    0                       0                   3
    ## 2                    0                       0                   2
    ## 3                    0                       1                   2
    ## 4                    0                       0                   0
    ## 5                    0                       0                   3
    ## 6                    0                       1                   2
    ##   fms_overhead_squat Stage
    ## 1                  2     9
    ## 2                  1     7
    ## 3                  1     6
    ## 4                  3     7
    ## 5                  2     7
    ## 6                  3     5

The R script, when ran, will categorize performance for the majority of
the variables into a file called mock_data_graded.csv which is stored in
the /output folder.

### Script \#2 - wellness_report_ind.Rmd

The second script,
[wellness_report_ind.Rmd](https://github.com/dbanderson1/police_fitness/blob/main/wellness_report_ind.Rmd),
will take the outputs from the first script and generate individualized
wellness reports. The reports will give officers an overview of their
physical fitness and is broken into four sections.

1.  Body Composition
2.  Physical Performance
3.  Flexibility and Mobility
4.  Comparison to the Force - for this section it is essential that you
    have completed all of your population’s physical testing. It will
    show them where they fall on a histogram of their peers and rank
    them into a percentile.

[This](https://github.com/dbanderson1/police_fitness/blob/main/output/wellness_report_ind.pdf)
is a sample what the reports look like.

## Instructions on Use

### Step 1. Clone the Repository

``` bash
git clone https://github.com/dbanderson1/police_fitness.git
```

### Step 2. Place the files

You only need two files to generate these reports:

1.  Your raw data files - in the case of this project it is
    mock_data.csv.
2.  Your department logo - which we have called logo.png

Both of those items should be located in the /input folder.

### Step 3. Run the First Script

Run
[catagorize_data.R](https://github.com/dbanderson1/police_fitness/blob/main/categorize_data.R)

### Step 4 Run the Second Script

[wellness_report_ind.Rmd](https://github.com/dbanderson1/police_fitness/blob/main/wellness_report_ind.Rmd)

Note: This script requires only three R packages:

``` bash
library(tidyverse)
library(knitr)
library(tinytex)
```

However, some users may need to install a full distribution of LaTeX,
for tinytex to work. The following distros are recommended:

1.  [MiKTeX](https://miktex.org/) for Windows/Linux
2.  [MacTeX](https://www.tug.org/mactex/) for macOS.

### Confirm functionality

You should be able to delete all files in the output folder and start
with your raw ungraded data and be able to generate reports. Change the
following line in the Second Script, to run a report on a different
participant.

``` bash
# --------------------------------------------------------------------------
# This is the key line to change to select which report to generate
# --------------------------------------------------------------------------
p <- df[df$Participant_num == "PFS_001", ][1, ]
```

## File Tree

File tree generated using r code and fs():

``` r
fs::dir_tree()
```

``` bash
.
├── categorize_data.R # Script One - Categorizes Data for Later Use
├── input # All of your inputs should be placed into this folder
│   ├── logo.png # Your Department's Logo Goes Here !
│   └── mock_data.csv # Your Raw Data Goes Here !
├── output # Here is where all your outputs are generated
│   ├── mock_data_graded.csv # this is your final graded data
│   ├── wellness_report_ind.md # MD version of the reports
│   ├── wellness_report_ind.pdf # PDF version of the reports
│   └── wellness_report_ind_files # thi is auto generated and contains the histograms you created
│       └── figure-gfm
│           ├── comparison-plots-1.png
│           ├── comparison-plots-2.png
│           ├── comparison-plots-3.png
│           ├── comparison-plots-4.png
│           ├── comparison-plots-5.png
│           ├── comparison-plots-6.png
│           ├── comparison-plots-7.png
│           ├── comparison-plots-8.png
│           └── comparison-plots-9.png
├── police_fitness.Rproj
├── README.md        # Top Level README
├── README.Rmd
└── wellness_report_ind.Rmd # Script Two - Generates Wellness Reports
```

## Future Directions

This project is the baseline foundation for several additional projects.

1.  Development of a third script which will batch process and generate
    100+ reports with Participant_num in the file name
2.  Overall report using graded data for the Chief of Police
3.  Using snippets of this script to develop similar wellness reports
    for US Army personnel

## Disclaimer:

All data contained in this repository are simulated (mock) data and do
not represent real individuals or operational police data. These data
are provided for illustrative and educational purposes only.
