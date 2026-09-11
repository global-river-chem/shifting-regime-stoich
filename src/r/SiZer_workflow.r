# ---- ## ----
# `SiZer` Workflow
# ---- ## ----
# code to be adapted for shifting-regime-stoich manuscript
# from: https://github.com/njlyon0/lter_silica-high-latitude/

# purpose:
# ---- run sizer workflow on data produced by wrtds ----
# ---- wrtds = weighted regressions on time, discharge, and season ----

# pre-requisites:
# ---- this script assumes you've done one of the following options: ----
# ---- a) run the "00_data-download.r" script ----
# ---- b) manually downloaded any needed inputs and put them in a folder named "data" ----

# ---- ## ----
# ---- housekeeping ----
# ---- ## ----

# need to force an install of heron to get an updated version?
# devtools::install_github("lter/HERON", force = T)

# load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, SiZer, supportR, lter / HERON)

# clear environment
rm(list = ls())
gc()

# make needed folder(s)
dir.create(path = file.path("data"), showWarnings = F)
dir.create(path = file.path("graphs"), showWarnings = F)

# download the data you need (or put it in the "data" folder manually)
# ---- note that you *must* have access to the relevant shared google drive for this to work ----
# source("00_data-download.R")

# load custom functions
purrr::walk(
  .x = dir(path = file.path("tools"), pattern = "fxn_"),
  .f = ~ source(file.path("tools", .x))
)

# ---- ## ----
# ---- general sizer prep ----
# ---- ## ----

# what is the temporal resolution of the wrtds output data?
# ---- *must* be one of "annual", "seasonal", or "monthly" ----
temporal_res <- "monthly"

# flexibly determine the needed resolution of wrtds output
if (stringr::str_detect(string = temporal_res, pattern = "annual")) {
  wrtds_file <- "Full_Results_WRTDS_annual.csv"
} else {
  wrtds_file <- "Full_Results_WRTDS_monthly.csv"
}

# read in data & rename a column
wrtds_v1 <- read.csv(file = file.path("data", wrtds_file))

# remove unwanted data / data that don't meet needed criteria
wrtds_v2 <- wrtds_v1 %>%
  # keep only lters at high latitudes
  dplyr::filter(
    LTER %in%
      c(
        "MCM",
        "GRO",
        "NIVA",
        "Krycklan",
        "Finnish Environmental Institute",
        "Canada",
        "Swedish Goverment"
      )
  ) %>%
  # drop some problem sites within wanted lters
  dplyr::filter(
    !Stream_Name %in%
      c(
        "Site 69038",
        "Kymijoki Ahvenkoski 001",
        "Kymijoki Kokonkoski 014",
        "BEAVER RIVER ABOVE HIGHWAY 1 IN GLACIER NATIONAL PARK",
        "KICKING HORSE RIVER AT FIELD IN YOHO NATIONAL PARK",
        "SKEENA RIVER AT USK",
        "KOOTENAY RIVER ABOVE HIGHWAY 93 IN KOOTENAY NATIONAL PARK",
        "Helgean Hammarsjon",
        "Ronnean Klippan",
        "Morrumsan Morrum",
        "Lyckebyan Lyckeby",
        "Lagan Laholm",
        "Nissan Halmstad",
        "Atran Falkenberg",
        "Alsteran Getebro",
        "Eman Emsfors",
        "Viskan Asbro",
        "Gota Alv Trollhattan",
        "Rane alv Niemisel",
        "Raan Helsingborg"
      )
  ) %>%
  # calculate number of years per stream
  dplyr::group_by(LTER, Stream_Name) %>%
  dplyr::mutate(num_years = length(unique(Year)), .after = Year) %>%
  dplyr::ungroup() %>%
  # keep only streams with more years than some threshold
  dplyr::filter(num_years >= 12) %>%
  # drop the year number column
  dplyr::select(-num_years)

# do some unit conversions / tidying
wrtds_v3 <- wrtds_v2 %>%
  # convert all of the 10^6 columns
  dplyr::mutate(
    dplyr::across(
      .cols = dplyr::contains("10_6k"),
      .fns = ~ ifelse(
        test = !chemical %in% c("Si:P", "Si:DIN"),
        yes = (.x * 10^6),
        no = NA
      )
    )
  ) %>%
  # rename those columns to reflect their new units
  dplyr::rename_with(
    .fn = ~ gsub(pattern = "10_6k", replacement = "k", x = .x),
    .cols = dplyr::contains("10_6k")
  ) %>%
  # tidy the chemical ratio names
  dplyr::mutate(
    chemical = dplyr::case_when(
      chemical == "Si:DIN" ~ "Si_DIN",
      chemical == "Si:P" ~ "Si_P",
      TRUE ~ chemical
    )
  ) %>%
  # rename stream column
  dplyr::rename(stream = Stream_Name)

# check structure
dplyr::glimpse(wrtds_v3)

# check that worked as desired
range(wrtds_v2$Yield_10_6kmol_yr_km2, na.rm = T)
range(wrtds_v3$Yield_kmol_yr_km2, na.rm = T)

# how many streams / lter remaining?
wrtds_v3 %>%
  dplyr::group_by(LTER) %>%
  dplyr::summarize(stream_ct = length(unique(stream)), .groups = "keep")

# check lost/gained columns
supportR::diff_check(old = names(wrtds_v1), new = names(wrtds_v3))

# duplicate the data object to reduce risk of accident
wrtds_v4 <- wrtds_v3

# if this dataset does not contain month/season columns (i.e., is annual) add them
if (!"Month" %in% names(wrtds_v3)) {
  wrtds_v4 <- dplyr::mutate(.data = wrtds_v4, Month = "x", .before = Year)
}
if (!"season" %in% names(wrtds_v3)) {
  wrtds_v4 <- dplyr::mutate(.data = wrtds_v4, season = "x", .before = Year)
}

# check structure
dplyr::glimpse(wrtds_v4)

# Remove months from McMurdo for which there shouldn't be data
wrtds_v5 <- wrtds_v4 %>%
  dplyr::filter(
    LTER != "MCM" |
      (LTER == "MCM" & Month %in% c("x", 12, 1, 2))
  )

# check that worked
wrtds_v5 %>%
  dplyr::filter(LTER == "MCM") %>%
  dplyr::pull(Month) %>%
  unique()

# ---- ## ----
# ---- variable selection ----
# ---- ## ----

# make a "final" version of the wrtds data
wrtds_v99 <- wrtds_v5

# choose response/explanatory variables of interest & focal chemical
response <- "Yield"
explanatory <- "Year"
element <- "DSi"

# check that combination of variables works
var_check(
  data = wrtds_v5,
  chem = element,
  resp_var = response,
  exp_var = explanatory
)

# prepare just the desired pieces of information
wrtds_focal <- wrtds_v99 %>%
  dplyr::select(LTER:chemical, dplyr::starts_with(response)) %>%
  dplyr::filter(chemical == element)

# check structure
dplyr::glimpse(wrtds_focal)

# create needed data sub-folder(s)
# ---- data output ----
(data_outs <- paste0("sizer-outs_", temporal_res))
dir.create(path = file.path("data", data_outs), showWarnings = F)
# ---- diagnostic graph outputs ----
(graph_outs <- paste(temporal_res, response, element, sep = "_"))
dir.create(path = file.path("graphs", graph_outs), showWarnings = F)

# ---- ## ----
# ---- core sizer workflow ----
# ---- ## ----

# make some empty lists to store different bits of information
data_list <- list()
statistic_list <- list()
estimate_list <- list()

# loop across streams
for (place in unique(wrtds_focal$stream)) {
  # for(place in "Iijoki Raasakan voimal"){

  # starting message
  message("Processing begun for ", element, " ", response, " at ", place)

  # make a shorter place name
  place_short <- stringr::str_sub(string = place, start = 1, end = 8)

  # subset to just this stream
  wrtds_place <- dplyr::filter(.data = wrtds_focal, stream == place)

  # handle each temporal resolution separately
  # ---- annual ----
  if (temporal_res == "annual") {
    # simply duplicate existing object
    wrtds_core <- wrtds_place

    # make some housekeeping objects that'll be useful in the processing script
    focal_season <- "x"
    focal_month <- "x"

    # and run workflow script
    source(file.path("tools", "flow_core-sizer-process.R"))

    # ---- seasonal ----
  } else if (temporal_res == "seasonal") {
    # make needed housekeeping object
    focal_month <- "x"

    # process the wrtds place object to get one row / season
    wrtds_place_v2 <- wrtds_place %>%
      # remove all instances where season info is missing
      dplyr::filter(!is.na(season)) %>%
      # drop some unwanted columns
      dplyr::select(-nDays, -DecYear) %>%
      # flip to long format to get all response variables into a single column
      tidyr::pivot_longer(
        cols = dplyr::starts_with(response),
        names_to = "var",
        values_to = "value"
      ) %>%
      # group by everything *except month* and average response values
      dplyr::group_by(LTER, stream, drainSqKm, season, Year, chemical, var) %>%
      dplyr::summarize(value = mean(value, na.rm = T), .groups = "keep") %>%
      dplyr::ungroup() %>%
      # flip back to wide format
      tidyr::pivot_wider(names_from = var, values_from = value)

    # loop across seasons
    for (focal_season in unique(wrtds_place_v2$season)) {
      # message current season
      message("Working on season: ", focal_season)

      # creating a season-specific subset
      wrtds_core <- dplyr::filter(
        .data = wrtds_place_v2,
        season == focal_season
      )

      # *then* running the workflow script
      source(file.path("tools", "flow_core-sizer-process.R"))
    } # close season loop

    # ---- monthly ----
  } else if (temporal_res == "monthly") {
    # make needed housekeeping object
    focal_season <- "x"

    # process the wrtds place object to get one row / month
    wrtds_place_v2 <- wrtds_place %>%
      # remove all instances where month info is missing
      dplyr::filter(!is.na(Month)) %>%
      # drop some unwanted columns
      dplyr::select(-nDays, -DecYear) %>%
      # flip to long format to get all response variables into a single column
      tidyr::pivot_longer(
        cols = dplyr::starts_with(response),
        names_to = "var",
        values_to = "value"
      ) %>%
      # group by everything *except season* and average response values
      dplyr::group_by(LTER, stream, drainSqKm, Month, Year, chemical, var) %>%
      dplyr::summarize(value = mean(value, na.rm = T), .groups = "keep") %>%
      dplyr::ungroup() %>%
      # flip back to wide format
      tidyr::pivot_wider(names_from = var, values_from = value)

    # loop across months
    for (focal_month in unique(wrtds_place_v2$Month)) {
      # message current month
      message("Working on month: ", focal_month)

      # creating a month-specific subset
      wrtds_core <- dplyr::filter(.data = wrtds_place_v2, Month == focal_month)

      # *then* running the workflow script
      source(file.path("tools", "flow_core-sizer-process.R"))
    } # close month loop
  } else {
    stop(
      "Unrecognized temporal resolution! Replace with one of 'annual', 'seasonal', or 'monthly'"
    )
  }
} # close processing loop

# ---- ## ----
# ---- process outputs ----
# ---- ## ----

# process the data first
data_actual <- purrr::list_rbind(x = data_list) %>%
  # tweak the '-inf to inf' entry for consistency with other dataframes and rename column
  dplyr::mutate(
    section = ifelse(
      groups == "(-Inf, Inf]",
      yes = "No inflection points",
      no = groups
    ),
    .after = LTER
  ) %>%
  # make end/start actually numbers and calculate duration of group
  dplyr::mutate(
    section_start = as.numeric(start),
    section_end = as.numeric(end),
    section_duration = section_end - section_start,
    .after = section_end
  ) %>%
  # remove redundant columns
  dplyr::select(-groups, -start, -end) %>%
  # drop non-unique rows
  dplyr::distinct()

# check structure
dplyr::glimpse(data_actual)

# wrangle the estimate outputs
estimate_actual <- purrr::list_rbind(x = estimate_list) %>%
  # remove intercept information
  dplyr::filter(term != "(Intercept)") %>%
  # drop term column now that it's all "data[[x]]"
  dplyr::select(-term) %>%
  # rename some columns for clarity
  dplyr::rename(
    std_error = std.error,
    term_statistic = statistic,
    term_p_value = p.value
  ) %>%
  # drop non-unique rows
  dplyr::distinct()

# check structure
dplyr::glimpse(estimate_actual)

# wrangle statistics outputs
statistic_actual <- purrr::list_rbind(x = statistic_list) %>%
  # replace periods with underscores in column names
  dplyr::rename_with(
    .fn = ~ gsub(pattern = "\\.", replacement = "_", x = .x),
    .cols = dplyr::contains(".")
  ) %>%
  # rename ambiguously named columns
  dplyr::rename(F_statistic = statistic, test_p_value = p_value) %>%
  # drop non-unique rows
  dplyr::distinct()

# check structure
dplyr::glimpse(statistic_actual)

# ---- ## ----
# ---- combine outputs ----
# ---- ## ----

# combine these three types of output
combo_v1 <- data_actual %>%
  # attach statistical information
  dplyr::left_join(
    y = statistic_actual,
    by = c("sizer_bandwidth", "stream", "section", "season", "Month")
  ) %>%
  # attach estimate information too
  dplyr::left_join(
    y = estimate_actual,
    by = c("sizer_bandwidth", "stream", "section", "season", "Month")
  )

# check structure
dplyr::glimpse(combo_v1)

# process this to make navigating it more intuitive/easier
combo_v2 <- combo_v1 %>%
  # reorder 'site information' (i.e., grouping columns) columns to the left
  dplyr::relocate(
    sizer_bandwidth,
    LTER,
    stream,
    drainSqKm,
    chemical,
    Month,
    season,
    Year,
    dplyr::contains(response),
    section,
    dplyr::starts_with("section_"),
    .before = dplyr::everything()
  ) %>%
  # rename columns as needed
  dplyr::rename(sizer_slope = slope_type) %>%
  # fix column class issues
  dplyr::mutate(
    sizer_bandwidth = as.numeric(sizer_bandwidth),
    Year = as.numeric(Year)
  ) %>%
  dplyr::mutate(dplyr::across(
    .cols = r_squared:std_error,
    .fns = as.numeric
  )) %>%
  dplyr::mutate(dplyr::across(
    .cols = dplyr::contains(response),
    .fns = as.numeric
  )) %>%
  # reorder statistical columns more informatively
  dplyr::relocate(
    F_statistic,
    test_p_value,
    r_squared,
    adj_r_squared,
    sigma,
    df,
    df_residual,
    nobs,
    logLik,
    AIC,
    BIC,
    deviance,
    .after = sizer_slope
  ) %>%
  dplyr::relocate(
    estimate,
    std_error,
    term_statistic,
    term_p_value,
    .after = dplyr::everything()
  ) %>%
  # rename slope estimate column more clearly
  dplyr::rename(slope_estimate = estimate, slope_std_error = std_error)

# check structure
dplyr::glimpse(combo_v2)

# create some other desired columns
combo_v3 <- combo_v2 %>%
  # simplify river names slightly
  dplyr::mutate(
    site_simp = gsub(pattern = " at", replacement = " ", x = stream)
  ) %>%
  # simplify other place information column contents
  dplyr::mutate(
    LTER_simp = ifelse(
      nchar(LTER) <= 4,
      yes = LTER,
      no = stringr::str_sub(LTER, start = 1, end = 4)
    ),
    site_simp = ifelse(
      nchar(site_simp) <= 14,
      yes = site_simp,
      no = stringr::str_sub(site_simp, start = 1, end = 14)
    ),
    LTER_stream = paste0(LTER_simp, "_", site_simp),
    .after = stream
  ) %>%
  # drop intermediary columns
  dplyr::select(-dplyr::ends_with("_simp")) %>%
  # Calculate average 'response' per SiZer section
  dplyr::group_by(sizer_bandwidth, stream, chemical, section) %>%
  dplyr::mutate(
    mean_response = mean(.data[[response]], na.rm = T),
    sd_response = sd(.data[[response]], na.rm = T),
    .before = section
  ) %>%
  dplyr::ungroup() %>%
  # express slope as a percent change of average response
  dplyr::mutate(
    percent_change = (slope_estimate / mean_response) * 100,
    .after = sd_response
  )

# Make sure the new 'LTER_stream' column is as unique as raw LTER + stream
length(unique(paste0(combo_v3$LTER, combo_v3$stream)))
length(unique(combo_v3$LTER_stream))

# check structure
dplyr::glimpse(combo_v3)

# make sure no columns are lost
supportR::diff_check(
  old = unique(c(
    names(data_actual),
    names(estimate_actual),
    names(statistic_actual)
  )),
  new = names(combo_v3)
)

# ---- ## ----
# ---- export ----
# ---- ## ----

# tweak the 'stream' column name to be more explicit
combo_v4 <- combo_v3 %>%
  dplyr::rename(Stream_Name = stream)

# final structure check
dplyr::glimpse(combo_v4)

# export that combination object locally
# ---- can use special folder name as *file name* to ensure informative naming conventions ----
write.csv(
  x = combo_v4,
  na = "",
  row.names = F,
  file = file.path("data", data_outs, paste0("sizer-outs_", graph_outs, ".csv"))
)

# ---- end ----
