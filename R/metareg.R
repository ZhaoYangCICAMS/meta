metareg <- function(x, formula,
                    method.tau = x$method.tau,
                    hakn = x$hakn,
                    level.comb = x$level.comb,
                    intercept = TRUE,
                    ...) {
  
  if ("data" %in% names(list(...))) {
    warning("Please note, argument 'data' has been renamed to 'x' in version 3.0-0 of R package meta (see help page of R function metareg). No meta-regression conducted.")
    return(invisible(NULL))
  }
  
  if (is.call(x)) {
    warning("Please note, first two arguments of R function metareg have been interchanged in version 3.0-0 of R package meta. No meta-regression conducted.")
    return(invisible(NULL))
  }
  
  
  ##
  ##
  ## (1) Check for meta object
  ##
  ##
  chkclass(x, "meta")
  
  
  ##
  ## Check whether R package metafor is installed
  ##
  is.installed.package("metafor", "metareg",
                       version = .settings$metafor)
  
  
  ##
  ## Assignments
  ##
  TE <- x$TE
  seTE <- x$seTE
  method <- x$method
  ##
  model.glmm <- x$model.glmm
  ##
  metabin <- inherits(x, "metabin")
  metainc <- inherits(x, "metainc")
  metaprop <- inherits(x, "metaprop")
  metarate <- inherits(x, "metarate")
  ##
  if (metabin) {
    event.e <- x$event.e
    n.e <- x$n.e
    event.c <- x$event.c
    n.c <- x$n.c
  }
  else if (metainc) {
    event.e <- x$event.e
    time.e <- x$time.e
    event.c <- x$event.c
    time.c <- x$time.c
  }
  else if (metaprop) {
    event <- x$event
    n <- x$n
  }
  else if (metarate) {
    event <- x$event
    time <- x$time
  }
  
  
  if (missing(formula))
    if (!is.null(x$data$.byvar))
      if (intercept)
        formula <- as.call(~ .byvar)
      else
        formula <- as.call(~ .byvar - 1)
        
    else {
      warning("No meta-regression conducted as argument 'formula' is missing and no information is provided on subgroup variable, i.e. list element 'byvar' in meta-analysis object 'x' (see help page of R function metareg).")
      return(invisible(NULL))
    }
  else {
    formula.text <- deparse(substitute(formula))
    formula.text <- gsub("~", "", formula.text)
    formula.text <- gsub("\\\"", "", formula.text)
    formula.text <- gsub("\\\'", "", formula.text)
    formula <- as.formula(paste("~", formula.text))
  }
  
  if (is.null(method.tau))
    method.tau <- "DL"
  ##
  method.tau <- setchar(method.tau,
                        c("DL", "PM", "REML", "ML", "HS", "SJ", "HE", "EB", "FE"))
  ##
  if (method.tau == "PM") {
    warning("Meta-regresion method not available for method.tau = \"PM\". Using REML method instead (method.tau = \"REML\").")
    method.tau <- "REML"
  }
  ##
  chklogical(hakn)
  ##
  chklevel(level.comb)
  chklogical(intercept)
  
  if (is.null(x$data)) {
    warning("Necessary data not available. Please, recreate meta-analysis object without option 'keepdata = FALSE'.")
    return(invisible(NULL))
  }
  
  
  ##
  ## Use subset of studies in meta-regression
  ##  
  if (!is.null(x$subset))
    dataset <- x$data[x$subset, ]
  else
    dataset <- x$data
  
  
  ##
  ## Exclude studies from meta-regression
  ## 
  if (!is.null(x$exclude)) {
    exclude <- dataset$.exclude
    dataset <- dataset[!dataset$.exclude, ]
  }
  else
    exclude <- rep(FALSE, nrow(dataset))
  
  
  ##
  ## Argument test in rma.uni() and rma.glmm()
  ##
  test <- ifelse(!hakn, "z",
                 ifelse(method != "GLMM", "knha", "t"))
  
  ##
  ## Covariate 'x' make problems without removing meta-analysis object x
  ##
  ..x <- x
  rm(x)
  ##
  if (method != "GLMM")
    res <- metafor::rma.uni(yi = TE[!exclude],
                            sei = seTE[!exclude],
                            data = dataset,
                            mods = formula, method = method.tau,
                            test = test, level = 100 * level.comb,
                            ...)
  else
    if (metabin)
      res <- metafor::rma.glmm(ai = event.e[!exclude], n1i = n.e[!exclude],
                               ci = event.c[!exclude], n2i = n.c[!exclude],
                               data = dataset,
                               mods = formula, method = method.tau,
                               test = test, level = 100 * level.comb,
                               measure = "OR", model = model.glmm,
                               ...)
    else if (metainc)
      res <- metafor::rma.glmm(x1i = event.e[!exclude], t1i = time.e[!exclude],
                               x2i = event.c[!exclude], t2i = time.c[!exclude],
                               data = dataset,
                               mods = formula, method = method.tau,
                               test = test, level = 100 * level.comb,
                               measure = "IRR", model = model.glmm,
                               ...)
    else if (metaprop)
      res <- metafor::rma.glmm(xi = event[!exclude], ni = n[!exclude],
                               data = dataset,
                               mods = formula, method = method.tau,
                               test = test, level = 100 * level.comb,
                               measure = "PLO",
                               ...)
    else if (metarate)
      res <- metafor::rma.glmm(xi = event[!exclude], ti = time[!exclude],
                               data = dataset,
                               mods = formula, method = method.tau,
                               test = test, level = 100 * level.comb,
                               measure = "IRLN",
                               ...)
  
  
  res$.meta <- list(x = ..x,
                    formula = formula,
                    method.tau = method.tau,
                    hakn = hakn,
                    level.comb = level.comb,
                    intercept = intercept,
                    dots = list(...),
                    call = match.call(),
                    version = packageDescription("meta")$Version,
                    version.metafor = packageDescription("metafor")$Version)

  class(res) <- c("metareg", class(res))
  
  res
}
