update.meta <- function(object, 
                        data = object$data,
                        subset = object$subset,
                        studlab = object$data$.studlab,
                        exclude = object$data$.exclude,
                        method = object$method,
                        sm = object$sm,
                        incr,
                        allincr = object$allincr,
                        addincr = object$addincr,
                        allstudies = object$allstudies,
                        MH.exact = object$MH.exact,
                        RR.cochrane = object$RR.cochrane,
                        model.glmm = object$model.glmm,
                        level = object$level,
                        level.comb = object$level.comb,
                        comb.fixed = object$comb.fixed,
                        comb.random = object$comb.random,
                        hakn = object$hakn,
                        method.tau = object$method.tau,
                        tau.preset = object$tau.preset,
                        TE.tau = object$TE.tau,
                        tau.common = object$tau.common,
                        prediction = object$prediction,
                        level.predict = object$level.predict,
                        null.effect = object$null.effect,
                        method.bias = object$method.bias,
                        ##
                        backtransf = object$backtransf,
                        pscale = object$pscale,
                        irscale = object$irscale,
                        irunit = object$irunit,
                        title = object$title,
                        complab = object$complab,
                        outclab = object$outclab,
                        label.e = object$label.e,
                        label.c = object$label.c,
                        label.left = object$label.left,
                        label.right = object$label.right,
                        n.e = object$n.e,
                        n.c = object$n.c,
                        pooledvar = object$pooledvar,
                        method.smd = object$method.smd,
                        sd.glass = object$sd.glass,
                        exact.smd = object$exact.smd,
                        method.ci = object$method.ci,
                        byvar = object$byvar,
                        bylab = object$bylab,
                        print.byvar = object$print.byvar,
                        byseparator = object$byseparator,
                        print.CMH = object$print.CMH,
                        keepdata = TRUE,
                        ##
                        left = object$left,
                        ma.fixed = object$ma.fixed,
                        type = object$type,
                        n.iter.max = object$n.iter.max,
                        ##
                        warn = object$warn,
                        ...) {
  
  
  ##
  ##
  ## (1) Check for meta object
  ##
  ##
  chkclass(object, "meta")
  ##
  metabin  <- inherits(object, "metabin")
  metacont <- inherits(object, "metacont")
  metacor  <- inherits(object, "metacor")
  metagen  <- inherits(object, "metagen")
  metainc  <- inherits(object, "metainc")
  metamean <- inherits(object, "metamean")
  metaprop <- inherits(object, "metaprop")
  metarate <- inherits(object, "metarate")
  
  
  ##
  ##
  ## (2) Replace missing arguments with defaults
  ##
  ##
  replacemiss <- function(x, replacement) {
    ##
    xnam <- deparse(substitute(x))
    ##
    if (is.null(x))
      if (missing(replacement))
        res <- gs(xnam)
      else
        res <- replacement
    else
      res <- x
    ##
    res
  }
  ##
  comb.fixed <- replacemiss(comb.fixed)
  comb.random <- replacemiss(comb.random)
  ##
  model.glmm <- replacemiss(model.glmm)
  ##
  level <- replacemiss(level)
  level.comb <- replacemiss(level.comb)
  ##
  hakn <- replacemiss(hakn)
  method.tau <- replacemiss(method.tau)
  tau.preset <- replacemiss(tau.preset)
  TE.tau <- replacemiss(TE.tau)
  null.effect <- replacemiss(null.effect, NA)
  method.bias <- replacemiss(method.bias)
  ##
  backtransf <- replacemiss(backtransf)
  label.left <- replacemiss(label.left)
  label.right <- replacemiss(label.right)
  ##
  tau.common <- replacemiss(tau.common)
  level.predict <- replacemiss(level.predict)
  prediction <- replacemiss(prediction)
  ##
  pscale  <- replacemiss(pscale, 1)
  irscale <- replacemiss(irscale, 1)
  irunit   <- replacemiss(irunit, 1)
  ##
  title <- replacemiss(title)
  complab <- replacemiss(complab)
  outclab <- replacemiss(outclab, "")
  label.e <- replacemiss(label.e)
  label.c <- replacemiss(label.c)
  ##
  print.byvar <- replacemiss(print.byvar)
  byseparator <- replacemiss(byseparator)
  ##
  warn <- replacemiss(warn)
  ##
  if (!backtransf & pscale != 1) {
    warning("Argument 'pscale' set to 1 as argument 'backtransf' is FALSE.")
    pscale <- 1
  }
  if (!backtransf & irscale != 1) {
    warning("Argument 'irscale' set to 1 as argument 'backtransf' is FALSE.")
    irscale <- 1
  }
  
  
  ##
  ##
  ## (3) Update trim-and-fill object
  ##
  ##
  if (inherits(object, "trimfill")) {
    ##
    rmfilled <- function(x) {
      ##
      if (!is.null(object[[x]]))
        res <- object[[x]][!object$trimfill]
      else
        res <- NULL
      ##
      res
    }
    ##
    tfnames <- c("TE", "seTE",
                 "studlab",
                 "n.e", "n.c",
                 "event.e", "event.c",
                 "mean.e", "mean.c", "sd.e", "sd.c",
                 "n", "event", "cor")
    ##
    for (i in tfnames)
      object[[i]] <- rmfilled(i)
    ##
    oldclass <- object$class.x
    ##
    res <- trimfill(object,
                    left = left, ma.fixed = ma.fixed,
                    type = type, n.iter.max = n.iter.max,
                    level = level, level.comb = level.comb,
                    comb.fixed = comb.fixed, comb.random = comb.random,
                    hakn = hakn,
                    method.tau = method.tau,
                    prediction = prediction, level.predict = level.predict,
                    silent = TRUE,
                    ...)
    ##
    res$call.object <- object$call
    res$call <- match.call()
    res$class.x <- oldclass
    ##
    return(res)
  }
  
  
  ##
  ##
  ## (4) Update metacum or metainf object
  ##
  ##
  if (inherits(object, "metacum") | inherits(object, "metainf")) {
    ##
    res <- object
    ##
    res$comb.fixed <- ifelse(res$pooled == "fixed", TRUE, FALSE)
    res$comb.random <- ifelse(res$pooled == "random", TRUE, FALSE)
    ##
    res$call.object <- object$call
    res$call <- match.call()
    res$version <- packageDescription("meta")$Version
    ##
    return(res)
  }
  
  
  ##
  ##
  ## (5) Prepare older meta object
  ##
  ##
  if (!(!is.null(object$version) &&
        as.numeric(unlist(strsplit(object$version, "-"))[1]) >= 3.2)) {
    ##
    ## Changes for meta objects with version < 3.2
    ##
    object$subset <- NULL
    ##
    object$data <- data.frame(.studlab = object$studlab,
                              .exclude = rep_len(FALSE, length(object$studlab)))
    ##
    if (!is.null(object$byvar))
      object$data$.byvar <- object$byvar
    ##
    if (metabin) {
      object$data$.event.e <- object$event.e
      object$data$.n.e <- object$n.e
      object$data$.event.c <- object$event.c
      object$data$.n.c <- object$n.c
    }
    ##
    if (metacont) {
      object$data$.n.e <- object$n.e
      object$data$.mean.e <- object$mean.e
      object$data$.sd.e <- object$sd.e
      object$data$.n.c <- object$n.c
      object$data$.mean.c <- object$mean.c
      object$data$.sd.c <- object$sd.c
    }
    ##
    if (metacor) {
      object$data$.cor <- object$cor
      object$data$.n <- object$n
    }
    ##
    if (metagen) {
      object$data$.TE <- object$TE
      object$data$.seTE <- object$seTE
    }
    ##
    if (metaprop) {
      object$data$.event <- object$event
      object$data$.n <- object$n
    }
  }
  ##
  if (!(!is.null(object$version) &&
        as.numeric(unlist(strsplit(object$version, "-"))[1]) >= 4.8)) {
    ##
    ## Changes for meta objects with version < 4.8
    ##
    if (metabin | metainc | metaprop | metarate)
      object$data$.incr <- object$incr
    ##
    if (metabin | metainc)
      if (object$method == "MH")
        object$k.MH <- sum(object$w.fixed > 0)
      else
        object$k.MH <- NA
  }
  ##
  if (is.null(object$data)) {
    warning("Necessary data not available. Please, recreate meta-analysis object without option 'keepdata = FALSE'.")
    return(invisible(NULL))
  }
  ##
  missing.subset  <- missing(subset)
  missing.incr    <- missing(incr)
  missing.byvar   <- missing(byvar)
  missing.studlab <- missing(studlab)
  missing.exclude <- missing(exclude)
  ##
  mf <- match.call()
  ##
  subset <- eval(mf[[match("subset", names(mf))]],
                 data, enclos = sys.frame(sys.parent()))
  ##
  incr <- eval(mf[[match("incr", names(mf))]],
               data, enclos = sys.frame(sys.parent()))
  ##
  byvar <- eval(mf[[match("byvar", names(mf))]],
                data, enclos = sys.frame(sys.parent()))
  ##
  if (!missing.byvar) {
    byvar.name <- as.character(mf[[match("byvar", names(mf))]])
    if (length(byvar.name) > 1 & byvar.name[1] == "$")
      byvar.name <- byvar.name[length(byvar.name)]
    if (length(byvar.name) > 1)
      byvar.name <- "byvar"
    ##
    bylab <- if (!missing(bylab) && !is.null(bylab)) bylab else byvar.name
  }
  ##
  studlab <- eval(mf[[match("studlab", names(mf))]],
                  data, enclos = sys.frame(sys.parent()))
  ##
  exclude <- eval(mf[[match("exclude", names(mf))]],
                  data, enclos = sys.frame(sys.parent()))
  ##
  if (missing.subset) {
    if (!is.null(object$subset))
      subset <- object$subset
    else if (!is.null(object$data$.subset))
      subset <- object$data$.subset
  }
  ##
  if (missing.incr) {
    if (!is.null(object$data$.incr))
      incr <- object$data$.incr
    else
      incr <- gs("incr")
  }
  ##
  if (missing.byvar & !is.null(object$data$.byvar))
    byvar <- object$data$.byvar
  ##
  if (missing.studlab & !is.null(object$data$.studlab))
    studlab <- object$data$.studlab
  ##
  if (missing.exclude & !is.null(object$data$.exclude))
    exclude <- object$data$.exclude
  ##
  if (method == "GLMM")
    if (metabin & !missing(sm) & sm != "OR")
      warning("Summary measure 'sm = \"OR\" used as 'method = \"GLMM\".")
    else if (metainc & !missing(sm) & sm != "IRR")
      warning("Summary measure 'sm = \"IRR\" used as 'method = \"GLMM\".")
    else if (metaprop & !missing(sm) & sm != "PLOGIT")
      warning("Summary measure 'sm = \"PLOGIT\" used as 'method = \"GLMM\".")
    else if (metarate & !missing(sm) & sm != "IRLN")
      warning("Summary measure 'sm = \"IRLN\" used as 'method = \"GLMM\".")
  
  
  ##
  ##
  ## (6) Update meta object
  ##
  ##
  if (metabin) {
    sm <- setchar(sm, .settings$sm4bin)
    method <- setchar(method, c("Inverse", "MH", "Peto", "GLMM"))
    if (sm == "ASD") {
      if (!missing.incr)
        warning("Note, no continuity correction considered for arcsine difference (sm = \"ASD\").")
      incr <- 0
      object$data$.incr <- 0
    }
    ##
    if (method == "Peto") {
      if (!missing.incr)
        warning("Note, no continuity correction considered for method = \"Peto\".")
      incr <- 0
      object$data$.incr <- 0
    }
    ##
    m <- metabin(event.e = object$data$.event.e,
                 n.e = object$data$.n.e,
                 event.c = object$data$.event.c,
                 n.c = object$data$.n.c,
                 ##
                 studlab = studlab,
                 exclude = exclude,
                 ##
                 data = data, subset = subset,
                 ##
                 method = method,
                 sm = ifelse(method == "GLMM", "OR", sm),
                 incr = incr,
                 allincr = allincr, addincr = addincr, allstudies = allstudies,
                 MH.exact = MH.exact, RR.cochrane = RR.cochrane,
                 model.glmm = model.glmm,
                 ##
                 level = level, level.comb = level.comb,
                 comb.fixed = comb.fixed, comb.random = comb.random,
                 ##
                 hakn = hakn, method.tau = ifelse(method == "GLMM", "ML", method.tau),
                 tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                 ##
                 prediction = prediction, level.predict = level.predict,
                 ##
                 method.bias = method.bias,
                 ##
                 backtransf = backtransf,
                 title = title, complab = complab, outclab = outclab,
                 label.e = label.e, label.c = label.c,
                 label.right = label.right, label.left = label.left,
                 ##
                 byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                 byseparator = byseparator,
                 print.CMH = print.CMH,
                 ##
                 keepdata = keepdata,
                 warn = warn,
                 ...)
  }
  ##
  if (metacont)
    m <- metacont(n.e = object$data$.n.e,
                  mean.e = object$data$.mean.e,
                  sd.e = object$data$.sd.e,
                  n.c = object$data$.n.c,
                  mean.c = object$data$.mean.c,
                  sd.c = object$data$.sd.c,
                  ##
                  studlab = studlab,
                  exclude = exclude,
                  ##
                  data = data, subset = subset,
                  ##
                  sm = sm, pooledvar = pooledvar,
                  method.smd = method.smd, sd.glass = sd.glass, exact.smd = exact.smd,
                  ##
                  level = level, level.comb = level.comb,
                  comb.fixed = comb.fixed, comb.random = comb.random,
                  ##
                  hakn = hakn, method.tau = method.tau,
                  tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                  ##
                  prediction = prediction, level.predict = level.predict,
                  ##
                  method.bias = method.bias,
                  ##
                  title = title, complab = complab, outclab = outclab,
                  label.e = label.e, label.c = label.c,
                  label.right = label.right, label.left = label.left,
                  ##
                  byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                  byseparator = byseparator,
                  ##
                  keepdata = keepdata,
                  warn = warn)
  ##
  if (metacor)
    m <- metacor(cor = object$data$.cor,
                 n = object$data$.n,
                 ##
                 studlab = studlab,
                 exclude = exclude,
                 ##
                 data = data, subset = subset,
                 ##
                 sm = sm,
                 ##
                 level = level, level.comb = level.comb,
                 comb.fixed = comb.fixed, comb.random = comb.random,
                 ##
                 hakn = hakn, method.tau = method.tau,
                 tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                 ##
                 prediction = prediction, level.predict = level.predict,
                 ##
                 null.effect = null.effect,
                 ##
                 method.bias = method.bias,
                 ##
                 backtransf = backtransf,
                 title = title, complab = complab, outclab = outclab,
                 byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                 byseparator = byseparator,
                 ##
                 keepdata = keepdata)
  ##
  if (metagen) {
    data.m <- data
    add.e <- FALSE
    add.c <- FALSE
    ##
    if ("n.e" %in% names(data)) {
      add.e <- TRUE
      data.m <- data.m[, names(data.m) != "n.e"]
    }
    if ("n.c" %in% names(data)) {
      add.c <- TRUE
      data.m <- data.m[, names(data.m) != "n.c"]
    }
    ##
    m <- metagen(TE = object$data$.TE,
                 seTE = object$data$.seTE,
                 ##
                 studlab = studlab,
                 exclude = exclude,
                 ##
                 data = data.m, subset = subset,
                 ##
                 sm = sm,
                 ##
                 level = level, level.comb = level.comb,
                 comb.fixed = comb.fixed, comb.random = comb.random,
                 ##
                 hakn = hakn, method.tau = method.tau,
                 tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                 ##
                 prediction = prediction, level.predict = level.predict,
                 ##
                 method.bias = method.bias,
                 ##
                 n.e = n.e, n.c = n.c,
                 ##
                 backtransf = backtransf,
                 title = title, complab = complab, outclab = outclab,
                 label.e = label.e, label.c = label.c,
                 label.right = label.right, label.left = label.left,
                 ##
                 byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                 byseparator = byseparator,
                 ##
                 keepdata = keepdata,
                 warn = warn)
    if (add.e)
      m$data$n.e <- data$n.e
    if (add.c)
      m$data$n.c <- data$n.c
    if (add.e | add.c)
      m$data <- m$data[, names(data)]
  }
  ##
  if (metainc) {
    data.m <- data
    add.e <- FALSE
    add.c <- FALSE
    ##
    if ("n.e" %in% names(data)) {
      add.e <- TRUE
      data.m <- data.m[, names(data.m) != "n.e"]
    }
    if ("n.c" %in% names(data)) {
      add.c <- TRUE
      data.m <- data.m[, names(data.m) != "n.c"]
    }
    ##
    m <- metainc(event.e = object$data$.event.e,
                 time.e = object$data$.time.e,
                 event.c = object$data$.event.c,
                 time.c = object$data$.time.c,
                 ##
                 studlab = studlab,
                 exclude = exclude,
                 ##
                 data = data, subset = subset,
                 ##
                 method = method,
                 sm = ifelse(method == "GLMM", "IRR", sm),
                 incr = incr,
                 allincr = allincr, addincr = addincr,
                 model.glmm = model.glmm,
                 ##
                 level = level, level.comb = level.comb,
                 comb.fixed = comb.fixed, comb.random = comb.random,
                 ##
                 hakn = hakn, method.tau = ifelse(method == "GLMM", "ML", method.tau),
                 tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                 ##
                 prediction = prediction, level.predict = level.predict,
                 ##
                 method.bias = method.bias,
                 ##
                 n.e = n.e, n.c = n.c,
                 ##
                 backtransf = backtransf,
                 title = title, complab = complab, outclab = outclab,
                 label.e = label.e, label.c = label.c,
                 label.right = label.right, label.left = label.left,
                 ##
                 byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                 byseparator = byseparator,
                 ##
                 keepdata = keepdata,
                 warn = warn,
                 ...)
    if (add.e)
      m$data$n.e <- data$n.e
    if (add.c)
      m$data$n.c <- data$n.c
    if (add.e | add.c)
      m$data <- m$data[, names(data)]
  }
  ##
  if (metamean)
    m <- metamean(n = object$data$.n,
                  mean = object$data$.mean,
                  sd = object$data$.sd,
                  ##
                  studlab = studlab,
                  exclude = exclude,
                  ##
                  data = data, subset = subset,
                  ##
                  sm = sm,
                  ##
                  level = level, level.comb = level.comb,
                  comb.fixed = comb.fixed, comb.random = comb.random,
                  ##
                  hakn = hakn, method.tau = method.tau,
                  tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                  ##
                  prediction = prediction, level.predict = level.predict,
                  ##
                  null.effect = null.effect,
                  ##
                  method.bias = method.bias,
                  ##
                  backtransf = backtransf,
                  title = title, complab = complab, outclab = outclab,
                  ##
                  byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                  byseparator = byseparator,
                  ##
                  keepdata = keepdata,
                  warn = warn)
  ##
  if (metaprop)
    m <- metaprop(event = object$data$.event,
                  n = object$data$.n,
                  ##
                  studlab = studlab,
                  exclude = exclude,
                  ##
                  data = data, subset = subset, method = method,
                  ##
                  sm = ifelse(method == "GLMM", "PLOGIT", sm),
                  incr = incr,
                  allincr = allincr, addincr = addincr,
                  method.ci = ifelse(is.null(method.ci), "CP", method.ci),
                  ##
                  level = level, level.comb = level.comb,
                  comb.fixed = comb.fixed, comb.random = comb.random,
                  ##
                  hakn = hakn, method.tau = ifelse(method == "GLMM", "ML", method.tau),
                  tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                  ##
                  prediction = prediction, level.predict = level.predict,
                  ##
                  null.effect = null.effect,
                  ##
                  method.bias = method.bias,
                  ##
                  backtransf = backtransf, pscale = pscale,
                  title = title, complab = complab, outclab = outclab,
                  byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                  byseparator = byseparator,
                  ##
                  keepdata = keepdata,
                  warn = warn,
                  ...)
  ##
  if (metarate)
    m <- metarate(event = object$data$.event,
                  time = object$data$.time,
                  ##
                  studlab = studlab,
                  exclude = exclude,
                  ##
                  data = data, subset = subset, method = method,
                  ##
                  sm = ifelse(method == "GLMM", "IRLN", sm),
                  incr = incr,
                  allincr = allincr, addincr = addincr,
                  method.ci = ifelse(is.null(method.ci), "CP", method.ci),
                  ##
                  level = level, level.comb = level.comb,
                  comb.fixed = comb.fixed, comb.random = comb.random,
                  ##
                  hakn = hakn, method.tau = ifelse(method == "GLMM", "ML", method.tau),
                  tau.preset = tau.preset, TE.tau = TE.tau, tau.common = tau.common,
                  ##
                  prediction = prediction, level.predict = level.predict,
                  ##
                  null.effect = null.effect,
                  ##
                  method.bias = method.bias,
                  ##
                  backtransf = backtransf, irscale = irscale, irunit = irunit,
                  title = title, complab = complab, outclab = outclab,
                  byvar = byvar, bylab = bylab, print.byvar = print.byvar,
                  byseparator = byseparator,
                  ##
                  keepdata = keepdata,
                  warn = warn,
                  ...)
  ##  
  m$call.object <- object$call
  m$call <- match.call()
  
  
  m
}
