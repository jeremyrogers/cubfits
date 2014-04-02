# Get the specific function accroding to the options.
get.my.drawBConditionalFit <- function(type){
  if(!any(type[1] %in% .CF.CT$type.B)){
    stop("type is not found.")
  }
  ret <- eval(parse(text = paste("my.drawBConditionalFit.",
                                 type[1], sep = "")))
  assign("my.drawBConditionalFit", ret, envir = .cubfitsEnv)
  ret
} # End of get.my.drawBConditionalFit().


# Draw new beta (M, S_1, S_2) from random walk.
my.drawBConditionalFit.Norm <- function(bFitaa, baa, phi, yaa, naa,
    drawScale = 1, reu13.df.aa = NULL){
  # Propose new beta.
  bHat <- bFitaa$coefficients
  R <- bFitaa$R / drawScale
  proplist <- my.propose.Norm(baa, bHat, R)

  # M-H step.
  ret <- my.drawBConditionalFit.MH(proplist, baa, phi, yaa, naa,
                                   drawScale = drawScale,
                                   reu13.df.aa = reu13.df.aa)
  ret
} # End of my.drawBConditionalFit.Norm().


# Utility function commonly for all my.drawBConditionalFit.*().
my.drawBConditionalFit.MH <- function(proplist, baa, phi, yaa, naa,
    drawScale = 1, reu13.df.aa = NULL){
  baaProp <- proplist$prop
  lir <- proplist$lir

  # Calculate posterior ratio.
  lpr <- .cubfitsEnv$my.logdmultinomCodOne(baaProp, phi, yaa, naa,
                                           reu13.df.aa = reu13.df.aa) -
         .cubfitsEnv$my.logdmultinomCodOne(baa, phi, yaa, naa,
                                           reu13.df.aa = reu13.df.aa)

  # log Acceptance probability.
  logAcceptProb <- lpr - lir
    
  # Error handling -- interpreting NaN etc. as ~= 0.
  if(!is.finite(logAcceptProb)){
    warning("log acceptance probability not finite in b draw")
    logAcceptProb <- -Inf
  }
    
  # Run MH acceptance rule.
  if(-rexp(1) < logAcceptProb){
    bNew <- baaProp
    accept <- 1
  } else{
    bNew <- baa
    accept <- 0
  }

  # Return.
  # ret <- list(bNew = bNew, accept = accept,
  #             lpr = lpr, lir = lir, bProp = baaProp)
  ret <- list(bNew = bNew, accept = accept)

  ret
} # End of my.drawBConditionalFit.MH().