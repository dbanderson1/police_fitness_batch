# ============================================================================
# Title:       PFS Wellness Categorization Script
# Author:      Derek Anderson
# Description: Script 1 of 2 — Reads raw fitness testing data (mock_data.csv),
#              applies normative category labels for key health and performance
#              measures, and writes the graded output (mock_data_graded.csv).
#
#              Categories are assigned using published age- and sex-stratified
#              normative tables for each measure. Sex is coded 0 = Male,
#              1 = Female throughout.
#
# Input:       mock_data.csv   — raw officer fitness data
# Output:      mock_data_graded.csv — same data with category columns appended
#
# Created:     18 April 2023
# Updated:     April 2026  — column names aligned to updated data dictionary;
#                             plank mm:ss parsing added; na.omit replaced with
#                             per-measure NA handling;
#                             vertical jump updated to Cooper Standard for Law
#                             Enforcement Physical Assessment (age- and sex-
#                             stratified; no data for males 59+ or females 50+);
#                             plank expanded to 7-category scale per Top End
#                             Sports with caveat re: lack of evidence-based
#                             cut-off scores;
#                             functional reach (§9) added — Spry norms,
#                             IQR-derived thresholds (Below / Average /
#                             Above Average), sex- and age-stratified.
# ============================================================================

# --------------------------------------------------------------------------
# 0. SETUP
# --------------------------------------------------------------------------

# Read data — Participant_num kept as a column (not row names) so it travels
# with the data through every join / export step.
Data <- read.csv("mock_data.csv", stringsAsFactors = FALSE)

# NOTE: We intentionally do NOT call na.omit() here.
# Some officers are missing cardiovascular data but have valid body-comp and
# strength data. Each categorization function handles its own NA checks, so
# partial records still receive every category they qualify for.

# --------------------------------------------------------------------------
# HELPER: Parse "mm:ss" strings into total seconds (numeric).
#
# The plank and CV-time columns arrive as character strings like "3:09".
# This function converts them to a single numeric value in seconds so the
# categorization logic can use standard comparisons.
# --------------------------------------------------------------------------
parse_mmss <- function(x) {
  # Return NA for empty / missing values
  if (is.na(x) || x == "") return(NA_real_)
  parts <- strsplit(as.character(x), ":")[[1]]
  as.numeric(parts[1]) * 60 + as.numeric(parts[2])
}

# Create numeric seconds columns for plank and CV time
Data$plank_sec <- sapply(Data$plank_mmss, parse_mmss)
Data$cv_time_sec <- sapply(Data$time_total_mmss, parse_mmss)

# --------------------------------------------------------------------------
# 1. BMI CATEGORIES
#
# Standard WHO classification. Cutoffs are the same for all ages and sexes.
#
# Category           BMI Range
# ─────────────────  ──────────
# Underweight        < 18.5
# Normal             18.5 – 24.9
# Overweight         25.0 – 29.9
# Obesity Class I    30.0 – 34.9
# Obesity Class II   35.0 – 39.9
# Obesity Class III  >= 40.0
# --------------------------------------------------------------------------

Data$BMI_cat <- NA

for (n in 1:nrow(Data)) {
  bmi <- Data$BMI[n]
  if (is.na(bmi)) next
  
  if (bmi < 18.5) {
    Data$BMI_cat[n] <- "Underweight"
  } else if (bmi <= 24.9) {
    Data$BMI_cat[n] <- "Normal"
  } else if (bmi <= 29.9) {
    Data$BMI_cat[n] <- "Overweight"
  } else if (bmi <= 34.9) {
    Data$BMI_cat[n] <- "Obesity Class I"
  } else if (bmi <= 39.9) {
    Data$BMI_cat[n] <- "Obesity Class II"
  } else {
    Data$BMI_cat[n] <- "Obesity Class III"
  }
}

# --------------------------------------------------------------------------
# 2. BODY FAT % CATEGORIES
#
# Source: ACSM Health-Related Physical Fitness Assessment Manual, 2nd Ed.,
#         2008, pg 59.
#         https://www.scribd.com/document/331711396/ACSM-Body-Composition
#
# Age- and sex-stratified ACSM norms.  "Essential Fat" category is omitted
# (values below the Excellent range are still labelled Excellent).
#
# Threshold vector = upper bound of each category, ordered best-to-worst:
#   c(excellent_upper, good_upper, average_upper, below_avg_upper)
#
# BF%  > below_avg_upper  → "Poor"
# BF%  > average_upper    → "Below Average"
# BF%  > good_upper       → "Average"
# BF%  > excellent_upper  → "Good"
# BF%  <= excellent_upper → "Excellent"
#
# ┌──────────────────────────────────────────────────────────────────────┐
# │  MALE                                                               │
# │  Category       20-29       30-39       40-49       50-59     60+   │
# │  Excellent      7.1-9.3    11.3-13.8   13.6-16.2  15.3-17.8 15.3-18.3│
# │  Good           9.4-14.0   13.9-17.4   16.3-19.5  17.9-21.2 18.4-21.9│
# │  Average       14.1-17.5   17.5-20.4   19.6-22.4  21.3-24.0 22.0-25.0│
# │  Below Average 17.6-22.4   20.5-24.1   22.5-26.0  24.1-27.4 25.1-28.4│
# │  Poor           >22.4       >24.2       >26.1       >27.5     >28.5  │
# ├──────────────────────────────────────────────────────────────────────┤
# │  FEMALE                                                             │
# │  Category       20-29       30-39       40-49       50-59     60+   │
# │  Excellent     14.5-17.0   15.5-17.9   18.5-21.2  21.6-24.9 21.1-25.0│
# │  Good          17.1-20.5   18.0-21.5   21.3-24.8  25.0-28.4 25.1-29.2│
# │  Average       20.6-23.6   21.6-24.8   24.9-28.0  28.5-31.5 29.3-32.4│
# │  Below Average 23.7-27.6   24.9-29.2   28.1-32.0  31.6-35.5 32.5-36.5│
# │  Poor           >27.7       >29.3       >32.1       >35.6     >36.6  │
# └──────────────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------

assign_bf_category <- function(sex, age, body_fat_pct) {
  if (is.na(sex) || is.na(age) || is.na(body_fat_pct)) return(NA)
  
  # --- Male thresholds: c(excellent_upper, good_upper, average_upper, below_avg_upper) ---
  male_thresholds <- list(
    `20-29` = c( 9.3, 14.0, 17.5, 22.4),
    `30-39` = c(13.8, 17.4, 20.4, 24.1),
    `40-49` = c(16.2, 19.5, 22.4, 26.0),
    `50-59` = c(17.8, 21.2, 24.0, 27.4),
    `60+`   = c(18.3, 21.9, 25.0, 28.4)
  )
  
  # --- Female thresholds: c(excellent_upper, good_upper, average_upper, below_avg_upper) ---
  female_thresholds <- list(
    `20-29` = c(17.0, 20.5, 23.6, 27.6),
    `30-39` = c(17.9, 21.5, 24.8, 29.2),
    `40-49` = c(21.2, 24.8, 28.0, 32.0),
    `50-59` = c(24.9, 28.4, 31.5, 35.5),
    `60+`   = c(25.0, 29.2, 32.4, 36.5)
  )
  
  # Determine age band
  age_band <- NA
  if      (age >= 20 & age <= 29) age_band <- "20-29"
  else if (age >= 30 & age <= 39) age_band <- "30-39"
  else if (age >= 40 & age <= 49) age_band <- "40-49"
  else if (age >= 50 & age <= 59) age_band <- "50-59"
  else if (age >= 60)             age_band <- "60+"
  
  if (is.na(age_band)) return(NA)
  
  # Select correct threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    thresholds <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    thresholds <- female_thresholds[[age_band]]
  } else {
    return(NA)
  }
  
  # Classify — check from worst to best
  if      (body_fat_pct > thresholds[4]) return("Poor")
  else if (body_fat_pct > thresholds[3]) return("Below Average")
  else if (body_fat_pct > thresholds[2]) return("Average")
  else if (body_fat_pct > thresholds[1]) return("Good")
  
  return("Excellent")
}

Data$BFperc_cat <- NA
for (n in 1:nrow(Data)) {
  Data$BFperc_cat[n] <- assign_bf_category(
    Data$Sex[n], Data$Age[n], Data$Body_Fat_perc[n]
  )
}

# --------------------------------------------------------------------------
# 3. VO2 MAX CATEGORIES
#
# Age- and sex-stratified cardiorespiratory fitness norms.
# Threshold vector = lower bounds in ascending order:
#   c(poor_min, fair_min, good_min, excellent_min, superior_min)
#
# >= threshold[5] = "Superior"   … down to < threshold[1] = "Very Poor"
# --------------------------------------------------------------------------

assign_vo2_category <- function(sex, age, vo2_max) {
  if (is.na(sex) || is.na(age) || is.na(vo2_max)) return(NA)
  
  # Determine age band
  age_band <- NA
  if      (age >= 20 & age <= 29) age_band <- "20-29"
  else if (age >= 30 & age <= 39) age_band <- "30-39"
  else if (age >= 40 & age <= 49) age_band <- "40-49"
  else if (age >= 50 & age <= 59) age_band <- "50-59"
  else if (age >= 60 & age <= 69) age_band <- "60-69"
  
  if (is.na(age_band)) return(NA)
  
  # --- Male thresholds ---
  male_thresholds <- list(
    `20-29` = c(35.5, 43.4, 49.1, 55.2, 61.9),
    `30-39` = c(32.8, 38.6, 43.9, 49.3, 56.6),
    `40-49` = c(29.1, 34.7, 39.0, 45.1, 52.2),
    `50-59` = c(24.3, 29.6, 33.9, 39.8, 45.7),
    `60-69` = c(21.3, 25.8, 29.2, 34.6, 40.4)
  )
  
  # --- Female thresholds ---
  female_thresholds <- list(
    `20-29` = c(26.3, 33.7, 39.0, 44.8, 51.4),
    `30-39` = c(22.6, 27.5, 31.3, 36.2, 41.5)
  )
  
  # Select correct threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    thresholds <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    thresholds <- female_thresholds[[age_band]]
  } else {
    return(NA)
  }
  
  # Classify (highest category first)
  if      (vo2_max >= thresholds[5]) return("Superior")
  else if (vo2_max >= thresholds[4]) return("Excellent")
  else if (vo2_max >= thresholds[3]) return("Good")
  else if (vo2_max >= thresholds[2]) return("Fair")
  else if (vo2_max >= thresholds[1]) return("Poor")
  
  return("Very Poor")
}

Data$VO2_cat <- NA
for (n in 1:nrow(Data)) {
  Data$VO2_cat[n] <- assign_vo2_category(
    Data$Sex[n], Data$Age[n], Data$VO2_max_est[n]
  )
}

# --------------------------------------------------------------------------
# 4. GRIP STRENGTH CATEGORIES  (per hand, lbs)
#
# Source: Squegg Hand Dynamometer White Paper
#         https://cdn.shopify.com/s/files/1/0846/2214/7873/files/
#         sqeugg_white_paper_final.pdf?v=1710446722
#
# Age- and sex-stratified, scored separately for dominant and non-dominant
# hand.  The published range represents the 25th–75th percentile (IQR).
#
#   Score < 25th percentile → "Below Average"
#   Score within 25th–75th  → "Average"
#   Score > 75th percentile → "Above Average"
#
# dom_hand in the data: 0 = Right dominant, 1 = Left dominant.
#
# Threshold vectors: c(p25, p75) — lower and upper bounds of average range.
#
# ┌────────────────────────────────────────────────────────────────────────┐
# │  MALE                                                                 │
# │  Age      Dom  (p25 – p75)    Non-Dom (p25 – p75)                    │
# │  18-20    68.4 – 119.0        69.5 – 111.1                           │
# │  20-30    71.1 – 117.9        70.7 – 110.2                           │
# │  30-40    73.7 – 114.3        71.3 – 107.1                           │
# │  40-50    73.8 – 108.5        70.0 – 102.0                           │
# │  50-60    71.6 – 100.5        66.9 –  94.8                           │
# │  60-70    67.0 –  90.1        61.9 –  85.4                           │
# │  70-80    60.0 –  77.6        55.0 –  74.0                           │
# │  80-90    50.6 –  62.8        46.4 –  60.6                           │
# ├────────────────────────────────────────────────────────────────────────┤
# │  FEMALE                                                               │
# │  Age      Dom  (p25 – p75)    Non-Dom (p25 – p75)                    │
# │  18-20    56.8 – 90.7         53.5 – 79.4                            │
# │  20-30    55.5 – 88.6         52.1 – 80.4                            │
# │  30-40    53.1 – 84.4         49.9 – 80.1                            │
# │  40-50    50.4 – 79.5         47.5 – 77.4                            │
# │  50-60    47.4 – 73.8         45.1 – 72.4                            │
# │  60-70    44.1 – 67.4         42.5 – 65.0                            │
# │  70-80    40.5 – 60.3         39.9 – 55.2                            │
# │  80-90    36.6 – 52.4         37.2 – 43.1                            │
# └────────────────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------

assign_gs_category <- function(sex, age, grip_lbs, is_dominant) {
  # Returns "Below Average", "Average", or "Above Average" for one hand.
  if (is.na(sex) || is.na(age) || is.na(grip_lbs) || is.na(is_dominant)) return(NA)
  
  # Determine age band (using lower-bound-inclusive decade convention from source)
  age_band <- NA
  if      (age >= 18 & age < 20) age_band <- "18-20"
  else if (age >= 20 & age < 30) age_band <- "20-30"
  else if (age >= 30 & age < 40) age_band <- "30-40"
  else if (age >= 40 & age < 50) age_band <- "40-50"
  else if (age >= 50 & age < 60) age_band <- "50-60"
  else if (age >= 60 & age < 70) age_band <- "60-70"
  else if (age >= 70 & age < 80) age_band <- "70-80"
  else if (age >= 80 & age < 90) age_band <- "80-90"
  
  if (is.na(age_band)) return(NA)
  
  # --- Male thresholds: list of c(p25, p75) for dom / non-dom ---
  male_dom <- list(
    `18-20` = c( 68.4, 119.0), `20-30` = c( 71.1, 117.9),
    `30-40` = c( 73.7, 114.3), `40-50` = c( 73.8, 108.5),
    `50-60` = c( 71.6, 100.5), `60-70` = c( 67.0,  90.1),
    `70-80` = c( 60.0,  77.6), `80-90` = c( 50.6,  62.8)
  )
  male_nondom <- list(
    `18-20` = c( 69.5, 111.1), `20-30` = c( 70.7, 110.2),
    `30-40` = c( 71.3, 107.1), `40-50` = c( 70.0, 102.0),
    `50-60` = c( 66.9,  94.8), `60-70` = c( 61.9,  85.4),
    `70-80` = c( 55.0,  74.0), `80-90` = c( 46.4,  60.6)
  )
  
  # --- Female thresholds ---
  female_dom <- list(
    `18-20` = c( 56.8, 90.7), `20-30` = c( 55.5, 88.6),
    `30-40` = c( 53.1, 84.4), `40-50` = c( 50.4, 79.5),
    `50-60` = c( 47.4, 73.8), `60-70` = c( 44.1, 67.4),
    `70-80` = c( 40.5, 60.3), `80-90` = c( 36.6, 52.4)
  )
  female_nondom <- list(
    `18-20` = c( 53.5, 79.4), `20-30` = c( 52.1, 80.4),
    `30-40` = c( 49.9, 80.1), `40-50` = c( 47.5, 77.4),
    `50-60` = c( 45.1, 72.4), `60-70` = c( 42.5, 65.0),
    `70-80` = c( 39.9, 55.2), `80-90` = c( 37.2, 43.1)
  )
  
  # Select the correct table based on sex and dominant/non-dominant
  if (sex == 0 && is_dominant)       tbl <- male_dom
  else if (sex == 0 && !is_dominant) tbl <- male_nondom
  else if (sex == 1 && is_dominant)  tbl <- female_dom
  else if (sex == 1 && !is_dominant) tbl <- female_nondom
  else return(NA)
  
  if (!(age_band %in% names(tbl))) return(NA)
  
  th <- tbl[[age_band]]  # c(p25, p75)
  
  if      (grip_lbs < th[1]) return("Below Average")
  else if (grip_lbs > th[2]) return("Above Average")
  else                       return("Average")
}

# Apply to each officer — map dom_hand to identify which measured hand is
# dominant vs non-dominant.
#   dom_hand: 0 = Right dominant  →  R = dom, L = non-dom
#   dom_hand: 1 = Left dominant   →  L = dom, R = non-dom

Data$GS_dom_cat    <- NA
Data$GS_nondom_cat <- NA

for (n in 1:nrow(Data)) {
  sex <- Data$Sex[n]
  age <- Data$Age[n]
  dh  <- Data$dom_hand[n]
  
  if (is.na(dh)) next
  
  if (dh == 0) {
    # Right-hand dominant
    dom_lbs    <- Data$grip_max_R_lbs[n]
    nondom_lbs <- Data$grip_max_L_lbs[n]
  } else {
    # Left-hand dominant
    dom_lbs    <- Data$grip_max_L_lbs[n]
    nondom_lbs <- Data$grip_max_R_lbs[n]
  }
  
  Data$GS_dom_cat[n]    <- assign_gs_category(sex, age, dom_lbs,    TRUE)
  Data$GS_nondom_cat[n] <- assign_gs_category(sex, age, nondom_lbs, FALSE)
}

# Left- and right-hand grip strength category labels.
# Maps the dom/non-dom categories back to anatomical hands so report inline
# text can reference "left hand" and "right hand" directly.
#   dom_hand: 0 = Right dominant  →  right = dom,    left = non-dom
#   dom_hand: 1 = Left dominant   →  left  = dom,    right = non-dom
Data$left_gs_cat  <- ifelse(Data$dom_hand == 0, Data$GS_nondom_cat, Data$GS_dom_cat)
Data$right_gs_cat <- ifelse(Data$dom_hand == 0, Data$GS_dom_cat,    Data$GS_nondom_cat)

# --------------------------------------------------------------------------
# 5. BENCH PRESS CATEGORIES  (number of repetitions completed)
#
# Source: Measurement and Evaluation in Human Performance, 3rd Ed.,
#         James R. Morrow et al., 2004, Table 11.20.
#         Adapted from Golding, Myers, and Sinning (1989).
#
# YMCA bench press test — reps to cadence at standardized load.
# Age- and sex-stratified.  Threshold vector = lower bound (minimum reps)
# for each category in ascending order:
#   c(poor_min, below_avg_min, avg_min, above_avg_min, good_min, excellent_min)
#
# Score >= excellent_min → "Excellent"  … down to score < poor_min → "Very Poor"
#
# ┌────────────────────────────────────────────────────────────────────────┐
# │  MALE  (reps)                                                         │
# │  Rating         18-25   26-35   36-45   46-55   56-65   66+           │
# │  Excellent      45-38   43-34   40-30   35-24   32-22   30-18         │
# │  Good           34-30   30-26   28-24   22-20   20-14   14-10         │
# │  Above Average  28-25   25-22   22-20   17-14   14-10   10-8          │
# │  Average        22-21   21-18   18-16   13-10   10-8     8-6          │
# │  Below Average  20-16   17-13   14-12   10-8     6-4     4-4          │
# │  Poor           13-9    12-9    10-8     6-4     4-2     2-2          │
# │  Very Poor       8-0     5-0     5-0     2-0      0       0           │
# ├────────────────────────────────────────────────────────────────────────┤
# │  FEMALE  (reps)                                                       │
# │  Rating         18-25   26-35   36-45   46-55   56-65   66+           │
# │  Excellent      50-36   48-33   46-28   42-26   34-22   26-18         │
# │  Good           32-28   29-25   25-21   22-20   20-16   14-12         │
# │  Above Average  25-22   22-20   20-17   17-13   15-12   11-9          │
# │  Average        21-18   18-16   14-12   12-10   10-8     8-5          │
# │  Below Average  16-13   14-12   11-9     9-6     7-4     4-2          │
# │  Poor           12-8     9-5     8-4     5-2     3-1     2-0          │
# │  Very Poor       5-1     2-0     2-0     1-0      0       0           │
# └────────────────────────────────────────────────────────────────────────┘
#
# NOTE: Ranges in the source table have small gaps between categories.
# Scores falling in a gap are assigned to the lower category (i.e., you
# must reach the floor of a category to earn that label).
# --------------------------------------------------------------------------

assign_bp_category <- function(sex, age, bp) {
  if (is.na(sex) || is.na(age) || is.na(bp)) return(NA)
  
  # Determine age band
  age_band <- NA
  if      (age >= 18 & age <= 25) age_band <- "18-25"
  else if (age >= 26 & age <= 35) age_band <- "26-35"
  else if (age >= 36 & age <= 45) age_band <- "36-45"
  else if (age >= 46 & age <= 55) age_band <- "46-55"
  else if (age >= 56 & age <= 65) age_band <- "56-65"
  else if (age >= 66)             age_band <- "66+"
  
  if (is.na(age_band)) return(NA)
  
  # --- Male thresholds: c(poor, below_avg, avg, above_avg, good, excellent) ---
  male_thresholds <- list(
    `18-25` = c( 9, 16, 21, 25, 30, 38),
    `26-35` = c( 9, 13, 18, 22, 26, 34),
    `36-45` = c( 8, 12, 16, 20, 24, 30),
    `46-55` = c( 4,  8, 10, 14, 20, 24),
    `56-65` = c( 2,  4,  8, 10, 14, 22),
    `66+`   = c( 2,  4,  6,  8, 10, 18)
  )
  
  # --- Female thresholds: c(poor, below_avg, avg, above_avg, good, excellent) ---
  female_thresholds <- list(
    `18-25` = c( 8, 13, 18, 22, 28, 36),
    `26-35` = c( 5, 12, 16, 20, 25, 33),
    `36-45` = c( 4,  9, 12, 17, 21, 28),
    `46-55` = c( 2,  6, 10, 13, 20, 26),
    `56-65` = c( 1,  4,  8, 12, 16, 22),
    `66+`   = c( 1,  2,  5,  9, 12, 18)
  )
  
  # Select correct threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    th <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    th <- female_thresholds[[age_band]]
  } else {
    return(NA)
  }
  
  # Classify — check from best to worst
  if      (bp >= th[6]) return("Excellent")
  else if (bp >= th[5]) return("Good")
  else if (bp >= th[4]) return("Above Average")
  else if (bp >= th[3]) return("Average")
  else if (bp >= th[2]) return("Below Average")
  else if (bp >= th[1]) return("Poor")
  
  return("Very Poor")
}

Data$BP_cat <- NA
for (n in 1:nrow(Data)) {
  Data$BP_cat[n] <- assign_bp_category(
    Data$Sex[n], Data$Age[n], Data$bench_press_reps[n]
  )
}

# --------------------------------------------------------------------------
# 6. VERTICAL JUMP CATEGORIES  (inches)
#
# Source: Cooper Standard for Law Enforcement Physical Assessment (Scored)
#
# Age- AND sex-stratified percentile norms.
# Categories map to percentile bands:
#   Superior   >= 95th percentile
#   Excellent  >= 80th percentile
#   Good       >= 60th percentile
#   Fair       >= 40th percentile
#   Poor       >= 20th percentile
#   Very Poor  <  20th percentile
#
# Threshold vector = minimum score (inches) to achieve each category,
# ordered ascending:
#   c(very_poor_min→poor, poor_min→fair, fair_min→good,
#     good_min→excellent, excellent_min→superior, superior_min)
# i.e. c(20th, 40th, 60th, 80th, 95th)
#
# NOTE: The Cooper Standard provides no data for Males 59+ or Females 50+.
#       Officers in those age bands will receive NA for VJ_cat.
#
# ┌──────────────────────────────────────────────────────────────────────┐
# │  MALE (inches)                                                      │
# │  Category    20-29   30-39   40-49   50-59                          │
# │  Superior    ≥26.5   ≥25.0   ≥22.0   ≥21.0                         │
# │  Excellent   ≥24.0   ≥22.0   ≥19.0   ≥17.0                         │
# │  Good        ≥21.5   ≥20.0   ≥17.0   ≥15.0                         │
# │  Fair        ≥20.0   ≥18.6   ≥15.5   ≥13.5                         │
# │  Poor        ≥17.5   ≥16.5   ≥14.0   ≥11.9                         │
# │  Very Poor   <17.5   <16.5   <14.0   <11.9                         │
# ├──────────────────────────────────────────────────────────────────────┤
# │  FEMALE (inches)                                                    │
# │  Category    20-29   30-39   40-49                                  │
# │  Superior    ≥18.8   ≥16.9   ≥13.5                                  │
# │  Excellent   ≥17.7   ≥15.0   ≥13.0                                  │
# │  Good        ≥15.9   ≥13.2   ≥11.5                                  │
# │  Fair        ≥14.0   ≥12.0   ≥ 9.6                                  │
# │  Poor        ≥12.6   ≥11.0   ≥ 7.8                                  │
# │  Very Poor   <12.6   <11.0   < 7.8                                  │
# └──────────────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------

assign_vj_category <- function(sex, age, vj) {
  if (is.na(sex) || is.na(age) || is.na(vj)) return(NA)
  
  # Threshold vector: c(20th, 40th, 60th, 80th, 95th)
  # Score >= 95th → Superior; >= 80th → Excellent; ... ; < 20th → Very Poor
  
  male_thresholds <- list(
    `20-29` = c(17.5, 20.0, 21.5, 24.0, 26.5),
    `30-39` = c(16.5, 18.6, 20.0, 22.0, 25.0),
    `40-49` = c(14.0, 15.5, 17.0, 19.0, 22.0),
    `50-59` = c(11.9, 13.5, 15.0, 17.0, 21.0)
    # 59+: no data available in Cooper Standard
  )
  
  female_thresholds <- list(
    `20-29` = c(12.6, 14.0, 15.9, 17.7, 18.8),
    `30-39` = c(11.0, 12.0, 13.2, 15.0, 16.9),
    `40-49` = c( 7.8,  9.6, 11.5, 13.0, 13.5)
    # 50+: no data available in Cooper Standard
  )
  
  # Determine age band
  age_band <- NA
  if      (age >= 20 & age <= 29) age_band <- "20-29"
  else if (age >= 30 & age <= 39) age_band <- "30-39"
  else if (age >= 40 & age <= 49) age_band <- "40-49"
  else if (age >= 50 & age <= 59) age_band <- "50-59"
  
  if (is.na(age_band)) return(NA)
  
  # Select threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    th <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    th <- female_thresholds[[age_band]]
  } else {
    return(NA)  # age band not covered for this sex
  }
  
  # Classify (highest category first)
  if      (vj >= th[5]) return("Superior")
  else if (vj >= th[4]) return("Excellent")
  else if (vj >= th[3]) return("Good")
  else if (vj >= th[2]) return("Fair")
  else if (vj >= th[1]) return("Poor")
  
  return("Very Poor")
}

Data$VJ_cat <- NA
for (n in 1:nrow(Data)) {
  Data$VJ_cat[n] <- assign_vj_category(
    Data$Sex[n], Data$Age[n], Data$vertical_jump_in[n]
  )
}

# --------------------------------------------------------------------------
# 7. PLANK CATEGORIES  (total seconds, parsed from mm:ss)
#
# Source: Top End Sports
#         https://www.topendsports.com/testing/tests/plank.htm
#
# NOTE: There do not appear to be evidence-based, well-accepted cut-off
#       scores for the plank test. The categories below are based on
#       general athletic reference ranges from the source above and should
#       be interpreted accordingly.
#
# Universal scale (not age- or sex-stratified).
#
# Category         Time
# ───────────────  ──────────────────────────
# Elite/Excellent  > 360 s  (> 6 min)
# Very Good        240 – 360 s  (4 – 6 min)
# Above Average    120 – 239 s  (2 – 4 min)
# Average           60 – 119 s  (1 – 2 min)
# Below Average     30 –  59 s
# Poor              15 –  29 s
# Very Poor          < 15 s
# --------------------------------------------------------------------------

Data$Plank_cat <- NA
for (n in 1:nrow(Data)) {
  plank <- Data$plank_sec[n]  # numeric seconds (parsed above)
  
  if (is.na(plank)) next
  
  if      (plank > 360)  Data$Plank_cat[n] <- "Elite/Excellent"
  else if (plank >= 240) Data$Plank_cat[n] <- "Very Good"
  else if (plank >= 120) Data$Plank_cat[n] <- "Above Average"
  else if (plank >= 60)  Data$Plank_cat[n] <- "Average"
  else if (plank >= 30)  Data$Plank_cat[n] <- "Below Average"
  else if (plank >= 15)  Data$Plank_cat[n] <- "Poor"
  else                   Data$Plank_cat[n] <- "Very Poor"
}

# --------------------------------------------------------------------------
# 8. SIT AND REACH CATEGORIES  (inches, max trial)
#
# Source: YMCA / Cooper Institute Sit and Reach Scale
#         Scale from testing device: https://lafayetteevaluation.com/products/121086-sit-reach-box
#
# Age- and sex-stratified percentile norms. Categories are assigned using the
# following percentile boundaries from the Cooper Institute / YMCA table:
#
#   >= 95th percentile → "Superior"
#   >= 80th percentile → "Excellent"
#   >= 60th percentile → "Good"
#   >= 40th percentile → "Fair"
#   >= 20th percentile → "Poor"
#   <  20th percentile → "Very Poor"
#
# Threshold vector = lower bounds in ascending order:
#   c(poor_20th, fair_40th, good_60th, excellent_80th, superior_95th)
#
# ┌────────────────────────────────────────────────────────────────────────┐
# │  MALE (inches)                                                        │
# │  Percentile  <20    20-29   30-39   40-49   50-59   60+               │
# │  95th (Sup)  23.4   23.0    22.0    21.3    20.5    20.0              │
# │  80th (Exc)  21.7   20.5    19.5    18.5    17.5    17.3              │
# │  60th (Good) 19.0   18.5    17.5    16.3    15.5    14.5              │
# │  40th (Fair) 16.5   16.5    15.5    14.3    13.3    12.5              │
# │  20th (Poor) 13.2   14.4    13.0    12.0    10.5    10.0              │
# ├────────────────────────────────────────────────────────────────────────┤
# │  FEMALE (inches)                                                      │
# │  Percentile  <20    20-29   30-39   40-49   50-59   60+               │
# │  95th (Sup)  24.3   24.5    24.0    22.8    23.0    23.0              │
# │  80th (Exc)  22.5   22.5    21.5    20.5    20.3    19.0              │
# │  60th (Good) 21.5   20.5    20.0    19.0    18.5    17.0              │
# │  40th (Fair) 20.5   19.3    18.3    17.3    16.8    15.5              │
# │  20th (Poor) 18.5   17.0    16.5    15.0    14.8    13.0              │
# └────────────────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------

assign_sr_category <- function(sex, age, sit_reach_score) {
  if (is.na(sex) || is.na(age) || is.na(sit_reach_score)) return(NA)
  
  # Determine age band
  age_band <- NA
  if      (age < 20)              age_band <- "<20"
  else if (age >= 20 & age <= 29) age_band <- "20-29"
  else if (age >= 30 & age <= 39) age_band <- "30-39"
  else if (age >= 40 & age <= 49) age_band <- "40-49"
  else if (age >= 50 & age <= 59) age_band <- "50-59"
  else if (age >= 60)             age_band <- "60+"
  
  if (is.na(age_band)) return(NA)
  
  # --- Male thresholds: c(20th, 40th, 60th, 80th, 95th) ---
  male_thresholds <- list(
    `<20`   = c(13.2, 16.5, 19.0, 21.7, 23.4),
    `20-29` = c(14.4, 16.5, 18.5, 20.5, 23.0),
    `30-39` = c(13.0, 15.5, 17.5, 19.5, 22.0),
    `40-49` = c(12.0, 14.3, 16.3, 18.5, 21.3),
    `50-59` = c(10.5, 13.3, 15.5, 17.5, 20.5),
    `60+`   = c(10.0, 12.5, 14.5, 17.3, 20.0)
  )
  
  # --- Female thresholds: c(20th, 40th, 60th, 80th, 95th) ---
  female_thresholds <- list(
    `<20`   = c(18.5, 20.5, 21.5, 22.5, 24.3),
    `20-29` = c(17.0, 19.3, 20.5, 22.5, 24.5),
    `30-39` = c(16.5, 18.3, 20.0, 21.5, 24.0),
    `40-49` = c(15.0, 17.3, 19.0, 20.5, 22.8),
    `50-59` = c(14.8, 16.8, 18.5, 20.3, 23.0),
    `60+`   = c(13.0, 15.5, 17.0, 19.0, 23.0)
  )
  
  # Select correct threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    thresholds <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    thresholds <- female_thresholds[[age_band]]
  } else {
    return(NA)
  }
  
  # Classify (highest category first)
  if      (sit_reach_score >= thresholds[5]) return("Superior")
  else if (sit_reach_score >= thresholds[4]) return("Excellent")
  else if (sit_reach_score >= thresholds[3]) return("Good")
  else if (sit_reach_score >= thresholds[2]) return("Fair")
  else if (sit_reach_score >= thresholds[1]) return("Poor")
  
  return("Very Poor")
}

Data$SR_cat <- NA
for (n in 1:nrow(Data)) {
  Data$SR_cat[n] <- assign_sr_category(
    Data$Sex[n], Data$Age[n], Data$sit_reach_in[n]
  )
}

# --------------------------------------------------------------------------
# 9. FUNCTIONAL REACH CATEGORIES  (inches)
#
# Source: Spry Functional Reach Test
#         https://www.sprypt.com/fot/functional-reach-test
#
# Age- and sex-stratified norms (mean ± SD) from the Spry source.
# Categories are derived using the IQR method, consistent with grip strength:
#
#   P25 = Mean − (0.675 × SD)   →  lower bound of "Average" range
#   P75 = Mean + (0.675 × SD)   →  upper bound of "Average" range
#
#   Below Average  score < P25
#   Average        P25 ≤ score ≤ P75
#   Above Average  score > P75
#
# ┌────────────────────────────────────────────────────────────────────────┐
# │  MEN                                                                  │
# │  Age Range   Mean (in)  SD     P25    P75                             │
# │  20–40       16.7       2.2    15.2   18.2                            │
# │  41–69       14.9       2.8    13.0   16.8                            │
# │  70–87       13.2       2.6    11.4   15.0                            │
# ├────────────────────────────────────────────────────────────────────────┤
# │  WOMEN                                                                │
# │  Age Range   Mean (in)  SD     P25    P75                             │
# │  20–40       14.6       2.2    13.1   16.1                            │
# │  41–69       13.8       2.2    12.3   15.3                            │
# │  70–87       10.5       3.5     8.1   12.9                            │
# └────────────────────────────────────────────────────────────────────────┘
# --------------------------------------------------------------------------

assign_fr_category <- function(sex, age, fr_score) {
  if (is.na(sex) || is.na(age) || is.na(fr_score)) return(NA)
  
  # Threshold vectors: c(p25, p75)
  # P25 = mean - 0.675*SD,  P75 = mean + 0.675*SD  (rounded to 1 dp)
  male_thresholds <- list(
    `20-40` = c(15.2, 18.2),
    `41-69` = c(13.0, 16.8),
    `70-87` = c(11.4, 15.0)
  )
  
  female_thresholds <- list(
    `20-40` = c(13.1, 16.1),
    `41-69` = c(12.3, 15.3),
    `70-87` = c( 8.1, 12.9)
  )
  
  # Determine age band (Spry uses broad bands)
  age_band <- NA
  if      (age >= 20 & age <= 40) age_band <- "20-40"
  else if (age >= 41 & age <= 69) age_band <- "41-69"
  else if (age >= 70 & age <= 87) age_band <- "70-87"
  
  if (is.na(age_band)) return(NA)
  
  # Select threshold table by sex
  if (sex == 0 && age_band %in% names(male_thresholds)) {
    th <- male_thresholds[[age_band]]
  } else if (sex == 1 && age_band %in% names(female_thresholds)) {
    th <- female_thresholds[[age_band]]
  } else {
    return(NA)
  }
  
  # Classify
  if      (fr_score > th[2]) return("Above Average")
  else if (fr_score >= th[1]) return("Average")
  
  return("Below Average")
}

Data$FR_cat <- NA
for (n in 1:nrow(Data)) {
  Data$FR_cat[n] <- assign_fr_category(
    Data$Sex[n], Data$Age[n], Data$functional_reach_in[n]
  )
}

# --------------------------------------------------------------------------
# 10. PRE-COMPUTED RMR-DERIVED DAILY CALORIE TARGETS
#
# Daily calorie ranges derived from resting metabolic rate (RMR_cal_d).
# Multipliers reflect activity-adjusted energy needs for different goals:
#
#   Goal              Multiplier range   Column
#   ─────────────     ────────────────   ──────────────────
#   Weight loss       1.1 × – 1.3 ×     rmr_loss_low / rmr_loss_high
#   Weight maintenance 1.4 × – 1.6 ×   rmr_maint_low / rmr_maint_high
#   Weight gain       1.7 ×             rmr_gain
# --------------------------------------------------------------------------

Data$rmr_loss_low   <- round(Data$RMR_cal_d * 1.1)
Data$rmr_loss_high  <- round(Data$RMR_cal_d * 1.3)
Data$rmr_maint_low  <- round(Data$RMR_cal_d * 1.4)
Data$rmr_maint_high <- round(Data$RMR_cal_d * 1.6)
Data$rmr_gain       <- round(Data$RMR_cal_d * 1.7)

# --------------------------------------------------------------------------
# 11. WRITE GRADED OUTPUT
# --------------------------------------------------------------------------

write.csv(Data, "mock_data_graded.csv", row.names = FALSE)

cat("Done — mock_data_graded.csv written with", nrow(Data), "rows and",
    ncol(Data), "columns.\n")

# Print a quick frequency table for each category to verify spread
cat("\n--- Category distributions ---\n")
for (cat_col in c("BMI_cat", "BFperc_cat", "VO2_cat", "GS_dom_cat",
                  "GS_nondom_cat", "left_gs_cat", "right_gs_cat",
                  "BP_cat", "VJ_cat", "Plank_cat", "SR_cat",
                  "FR_cat")) {
  cat(paste0("\n", cat_col, ":\n"))
  print(table(Data[[cat_col]], useNA = "ifany"))
}