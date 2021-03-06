backtransf <- function(x, sm, value, n, warn = FALSE) {
  
  ##
  ## Do nothing if all values are NA
  ## 
  if (all(is.na(x)))
    return(x)
  
  if (is.relative.effect(sm) | is.log.effect(sm))
    res <- exp(x)
  ##
  else if (sm == "ZCOR")
    res <- z2cor(x)
  ##
  else if (sm == "PLOGIT")
    res <- logit2p(x)
  ##
  else if (sm == "PAS")
    res <- asin2p(x, value = value, warn = warn)
  ##
  else if (sm == "PFT")
    res <- asin2p(x, n, value = value, warn = warn)
  ##
  else if (sm == "IRS")
    res <- x^2
  ##
  else if (sm == "IRFT")
    res <- asin2ir(x, n, value = value, warn = warn)
  ##
  else
    res <- x

  if (sm == "PRAW") {
    sel0 <- res[!is.na(res)] < 0 & value == "lower"
    sel1 <- res[!is.na(res)] > 1 & value == "upper"
    ##
    if (warn & any(sel0 | sel1, na.rm = TRUE))
      warning("Negative value for ",
              if (length(x) > 1) "at least one ",
              if (value == "lower") "lower confidence limit of raw proportions.\n  Lower confidence limit set to 0.",
              if (value == "upper") "upper confidence limit of raw proportions.\n  Upper confidence limit set to 1.",
              sep = "")
    if (any(sel0, na.rm = TRUE) & value == "lower")
      res[sel0] <- 0
    else if (any(sel1, na.rm = TRUE) & value == "upper")
      res[sel1] <- 1
  }
  
  if (sm == "PLN") {
    sel0 <- res[!is.na(res)] < 0 & value == "lower"
    sel1 <- res[!is.na(res)] > 1 & value == "upper"
    ##
    if (warn & any(sel0 | sel1, na.rm = TRUE))
      warning("Negative value for ",
              if (length(x) > 1) "at least one ",
              if (value == "lower") "lower confidence limit using log transformation for proportions.\n  Lower confidence limit set to 0.",
              if (value == "upper") "upper confidence limit using log transformation for proportions.\n  Upper confidence limit set to 1.",
              sep = "")
    if (any(sel0, na.rm = TRUE) & value == "lower")
      res[sel0] <- 0
    else if (any(sel1, na.rm = TRUE) & value == "upper")
      res[sel1] <- 1
  }
  
  if (sm == "IR") {
    sel0 <- res[!is.na(res)] < 0 & value == "lower"
    ##
    if (warn & any(sel0, na.rm = TRUE))
      warning("Negative value for ",
              if (length(x) > 1) "at least one ",
              if (value == "lower") "lower confidence limit of incidence rates.\n  Lower confidence limit set to 0.",
              sep = "")
    if (any(sel0, na.rm = TRUE) & value == "lower")
      res[sel0] <- 0
  }

  res
}
