##' AUTHOR: Cole Brookson
##' DATE OF CREATION: 2023-04-11
#'
#' This file contains functions to calculate the permutation entropy for each of
#' the datasets in the EFI Neon Forecasting challenge
#'
#' All functions are documented using the roxygen2 framework and the docstring
#' library
#'

#' Calculate permutation entropy for the acquatics challenge
#'
#' @description Do the various data chopping that should be done to get the
#' aquatics
#'
#' @param df A dataframe of the daily aquatics challenge
#' @param output_path character. Where to save the outputs of the computation
#' @param fig_path character. Where to save any figures generated
#'
#' @usage aquatics_daily_wpe(df, data_path, fig_path)
#' @return a named list containing all of the variations of the permutation
#' entropy calculations
aquatics_daily_wpe <- function(df, output_path, fig_path) {

}

df <- get_data_csv(
  here::here("./data/efi-neon-data/aquatic-daily.csv")
)

df <- data.frame(
  datetime = seq(as.Date(min(df$datetime)), as.Date(max(df$datetime)),
    by = "days"
  )
) %>%
  dplyr::left_join(
    .,
    y = df,
    by = "datetime"
  )

aquat_daily_wpe <- expand.grid(
  site = unique(df$site_id),
  var = unique(df$variable),
  gap = c(NA, 2, 3, 5, 7)
) %>%
  dplyr::filter(
    !is.na(var) & !is.na(site)
  )
aquat_daily_wpe$wpe <- NA

for (i in seq_len(nrow(aquat_daily_wpe))) {
  rolling <- aquat_daily_wpe[i, "gap"]
  df_temp <- df[which(df$variable == aquat_daily_wpe[i, "var"] &
    which(df$site_id == aquat_daily_wpe[i, "site"])), ]
  if (!is.na(aquat_daily_wpe[i, "gap"])) {
    df_fill_options <- make_groups(
      df = df_temp,
      groupings = rolling
    )
    df_roll <- df_fill_options %>%
      dplyr::group_by(.data[[paste0("grouping_", rolling, "d")]]) %>%
      dplyr::summarize(
        mean_datetime = mean(datetime),
        mean_obs = mean(observation, na.rm = TRUE)
      )
    # calculate WPE on the variable in question
    aquat_daily_wpe[i, "wpe"] <- PE(df_roll$mean_obs,
      word_length = 3,
      weighted = TRUE, tie_method = "average", tau = 1
    )
  }
  # do it on the data where it's not an NA thing
  aquat_daily_wpe[i, "wpe"] <- PE(df_temp$observation,
    word_length = 3,
    weighted = TRUE, tie_method = "average", tau = 1
  )
  if ((i %% 10) == 0) {
    print(i)
  }
}
aquat_daily_wpe$gap <- as.factor(aquat_daily_wpe$gap)
aquat_daily_wpe$var <- as.factor(aquat_daily_wpe$var)

ggplot(data = aquat_daily_wpe) +
  geom_density(aes(x = wpe)) +
  theme_base()
ggplot(data = aquat_daily_wpe) +
  geom_violin(aes(x = gap, y = wpe)) +
  theme_base()

ggplot(data = aquat_daily_wpe) +
  geom_point(aes(x = var, y = wpe)) +
  theme_base()


ggsave(
  here::here("./figs/TEMP.png"),
  ggplot(data = aquat_daily_wpe) +
    geom_point(aes(x = site, y = wpe, colour = var)) +
    theme_base()
)
ggplot(data = aquat_daily_wpe) +
  geom_point(aes(x = site, y = wpe, colour = var)) +
  theme_base()
