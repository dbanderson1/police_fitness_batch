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

The raw data for your script should be placed in the /input folder. It
should have the following file structure:

``` r
colnames(read.csv("input/mock_data.csv"))
```

    ##  [1] "Participant_num"         "Sex"                    
    ##  [3] "Age"                     "height_in"              
    ##  [5] "height_cm"               "weight_lbs"             
    ##  [7] "weight_kg"               "BMI"                    
    ##  [9] "BMD_g_cm2"               "BMD_perc"               
    ## [11] "BMC_lbs"                 "Body_Fat_perc"          
    ## [13] "total_mass_lbs"          "lean_muscle_mass_perc"  
    ## [15] "lean_muscle_mass_lbs"    "fat_mass_lbs"           
    ## [17] "RMR_cal_d"               "CV_test"                
    ## [19] "HR_resting_seated"       "time_total_mmss"        
    ## [21] "HR_max_test"             "HR_85perc_max"          
    ## [23] "VO2_max_est"             "dom_hand"               
    ## [25] "grip_max_L_lbs"          "grip_max_R_lbs"         
    ## [27] "grip_max_sum_lbs"        "vertical_jump_in"       
    ## [29] "bench_press_reps"        "plank_mmss"             
    ## [31] "sit_reach_in"            "functional_reach_in"    
    ## [33] "fms_pain_L_scap"         "fms_pain_R_scap"        
    ## [35] "fms_pain_press_prone"    "fms_pain_posterior_rock"
    ## [37] "fms_modified_pushup"     "fms_overhead_squat"     
    ## [39] "Stage"

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

### Step 4. Run the Second Script

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

### Step 5. Confirm functionality

You should be able to delete all files in the output folder and start
with your raw ungraded data and be able to generate reports. Change the
following code (line 32) in the Second Script, to run a report on a
different participant.

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
│   └── wellness_report_ind_files # this is auto generated and contains the histograms you created
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
