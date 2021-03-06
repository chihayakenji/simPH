#' Simulate quantities of interest for linear time constant covariates from Cox Proportional Hazards models
#'
#' \code{coxsimLinear} simulates relative hazards, first differences, and hazard ratios for time-constant covariates from models estimated with \code{\link{coxph}} using the multivariate normal distribution. These can be plotted with \code{\link{simGG}}.
#' @param obj a \code{\link{coxph}} class fitted model object.
#' @param b character string name of the coefficient you would like to simulate.
#' @param qi quantity of interest to simulate. Values can be \code{"Relative Hazard"}, \code{"First Difference"}, \code{"Hazard Ratio"}, and \code{"Hazard Rate"}. The default is \code{qi = "Relative Hazard"}. If \code{qi = "Hazard Rate"} and the \code{coxph} model has strata, then hazard rates for each strata will also be calculated.
#' @param Xj numeric vector of fitted values for \code{b} to simulate for.
#' @param Xl numeric vector of values to compare \code{Xj} to. Note if \code{code = "Relative Hazard"} only \code{Xj} is relevant.
#' @param means logical, whether or not to use the mean values to fit the hazard rate for covaraiates other than \code{b}. 
#' @param nsim the number of simulations to run per value of X. Default is \code{nsim = 1000}. Note: it does not currently support models that include polynomials created by \code{\link{I}}.
#' @param ci the proportion of simulations to keep. The default is \code{ci = 0.95}, i.e. keep the middle 95 percent. If \code{spin = TRUE} then \code{ci} is the confidence level of the shortest probability interval. Any value from 0 through 1 may be used.
#' @param spin logical, whether or not to keep only the shortest probability interval rather than the middle simulations.
#'
#' @return a \code{simlinear} object
#'
#' @description Simulates relative hazards, first differences, hazard ratios, and hazard rates for linear time-constant covariates from Cox Proportional Hazard models. These can be plotted with \code{\link{simGG}}.
#'
#'
#' @examples
#' # Load Carpenter (2002) data
#' data("CarpenterFdaData")
#'
#' # Load survival package
#' library(survival)
#'
#' # Run basic model
#' M1 <- coxph(Surv(acttime, censor) ~ prevgenx + lethal +
#'             deathrt1 + acutediz + hosp01  + hhosleng +
#'             mandiz01 + femdiz01 + peddiz01 + orphdum +
#'             vandavg3 + wpnoavg3 + condavg3 + orderent +
#'             stafcder, data = CarpenterFdaData)
#'
#' # Simulate Hazard Ratios
#' Sim1 <- coxsimLinear(M1, b = "stafcder", 
#'                        Xj = c(1237, 1600), 
#'                        Xl = c(1000, 1000), 
#'                        spin = TRUE, ci = 0.99)
#'
#' ## dontrun
#' # Simulate Hazard Rates
#' # Sim2 <- coxsimLinear(M1, b = "stafcder", 
#' #                       qi = "Hazard Rate", 
#' #                       Xj = 1237, 
#' #                       ci = 0.99, means = TRUE)
#'
#' @seealso \code{\link{simGG}}, \code{\link{survival}}, \code{\link{strata}}, and \code{\link{coxph}}
#' @references Licht, Amanda A. 2011. ''Change Comes with Time: Substantive Interpretation of Nonproportional Hazards in Event History Analysis.'' Political Analysis 19: 227-43.
#'
#' King, Gary, Michael Tomz, and Jason Wittenberg. 2000. ''Making the Most of Statistical Analyses: Improving Interpretation and Presentation.'' American Journal of Political Science 44(2): 347-61.
#' 
#' Liu, Ying, Andrew Gelman, and Tian Zheng. 2013. ''Simulation-Efficient Shortest Probability Intervals.'' Arvix. \url{http://arxiv.org/pdf/1302.2142v1.pdf}.
#'
#' @import data.table
#' @importFrom reshape2 melt
#' @importFrom survival basehaz
#' @importFrom MSBVAR rmultnorm
#' @export

coxsimLinear <- function(obj, b, qi = "Relative Hazard", Xj = NULL, Xl = NULL, means = FALSE, nsim = 1000, ci = 0.95, spin = FALSE)
{	
  QI <- NULL
  if (qi != "Hazard Rate" & isTRUE(means)){
    stop("means can only be TRUE when qi = 'Hazard Rate'.")
  }

  if (is.null(Xl) & qi != "Hazard Rate"){
    Xl <- rep(0, length(Xj))
    message("All Xl set to 0.")
  } else if (!is.null(Xl) & qi == "Relative Hazard") {
    message("All Xl set to 0.")
  }

  # Ensure that qi is valid
  qiOpts <- c("Relative Hazard", "First Difference", "Hazard Rate", "Hazard Ratio")
  TestqiOpts <- qi %in% qiOpts
  if (!isTRUE(TestqiOpts)){
    stop("Invalid qi type. qi must be 'Relative Hazard', 'Hazard Rate', 'First Difference', or 'Hazard Ratio'")
  }
  MeansMessage <- NULL
  if (isTRUE(means) & length(obj$coefficients) == 3){
    means <- FALSE
    MeansMessage <- FALSE
    message("Note: means reset to FALSE. The model only includes the interaction variables.")
  } else if (isTRUE(means) & length(obj$coefficients) > 3){
    MeansMessage <- TRUE
  }

  # Parameter estimates & Variance/Covariance matrix
	Coef <- matrix(obj$coefficients)
	VC <- vcov(obj)
	
	# Draw covariate estimates from the multivariate normal distribution	    
	Drawn <- rmultnorm(n = nsim, mu = Coef, vmat = VC)
	DrawnDF <- data.frame(Drawn)
	dfn <- names(DrawnDF)

  # If all values aren't set for calculating the hazard rate
  if (!isTRUE(means)){

  	# Subset simulations to only include b
  	bpos <- match(b, dfn)
  	Simb <- data.frame(DrawnDF[, bpos])
  	names(Simb) <- "Coef"

    # Find quantity of interest
    if (qi == "Relative Hazard"){
      Xs <- data.frame(Xj)
      names(Xs) <- c("Xj")
      Xs$Comparison <- paste(Xs[, 1])
      Simb <- merge(Simb, Xs)
      Simb$QI <- exp(Simb$Xj * Simb$Coef) 
    } else if (qi == "First Difference"){
	    Xs <- data.frame(Xj, Xl)
	    Simb <- merge(Simb, Xs)
	    Simb$QI<- (exp((Simb$Xj - Simb$Xl) * Simb$Coef) - 1) * 100
    }
    else if (qi == "Hazard Ratio"){
    	Xs <- data.frame(Xj, Xl)
	    Simb <- merge(Simb, Xs)
  	  Simb$QI<- exp((Simb$Xj - Simb$Xl) * Simb$Coef)	
    }
    else if (qi == "Hazard Rate"){
        Xl <- NULL
        message("Xl is ignored.")

        if (isTRUE(MeansMessage)){
          message("All variables values other than b are fitted at 0.")
        } 
      	Xs <- data.frame(Xj)
      	Xs$HRValue <- paste(Xs[, 1])
  	    Simb <- merge(Simb, Xs)
        Simb$HR <- exp(Simb$Xj * Simb$Coef)	 
  	  	bfit <- basehaz(obj)
  	  	bfit$FakeID <- 1
  	  	Simb$FakeID <- 1
        bfitDT <- data.table(bfit, key = "FakeID", allow.cartesian = TRUE)
        SimbDT <- data.table(Simb, key = "FakeID", allow.cartesian = TRUE)
        SimbCombDT <- SimbDT[bfitDT, allow.cartesian=TRUE]
        Simb <- data.frame(SimbCombDT)
  	  	Simb$QI <- Simb$hazard * Simb$HR
  	  	Simb <- Simb[, -1]
    }
  }

  # If the user wants to calculate Hazard Rates using means for fitting all covariates other than b.
  else if (isTRUE(means)){
    Xl <- NULL
    message("Xl ignored")

    # Set all values of b at means for data used in the analysis
    NotB <- setdiff(names(DrawnDF), b)
    MeanValues <- data.frame(obj$means)
    FittedMeans <- function(Z){
      ID <- 1:nsim
      Temp <- data.frame(ID)
      for (i in Z){
        BarValue <- MeanValues[i, ]
        DrawnCoef <- DrawnDF[, i]
        FittedCoef <- outer(DrawnCoef, BarValue)
        FCMolten <- data.frame(melt(FittedCoef))
        Temp <- cbind(Temp, FCMolten[,3])
      }
      Names <- c("ID", Z)
      names(Temp) <- Names
      Temp <- Temp[, -1]
      return(Temp)
    }
    FittedComb <- FittedMeans(NotB) 
    ExpandFC <- do.call(rbind, rep(list(FittedComb), length(Xj)))

    # Set fitted values for Xj
    bpos <- match(b, dfn)
    Simb <- data.frame(DrawnDF[, bpos])

    Xs <- data.frame(Xj)
    Xs$HRValue <- paste(Xs[, 1])

    Simb <- merge(Simb, Xs)
    Simb$CombB <- Simb[, 1] * Simb[, 2]
    Simb <- Simb[, 2:4]

    Simb <- cbind(Simb, ExpandFC)
    Simb$Sum <- rowSums(Simb[, c(-1, -2)])
    Simb$HR <- exp(Simb$Sum)

    bfit <- basehaz(obj)
    bfit$FakeID <- 1
    Simb$FakeID <- 1
    bfitDT <- data.table(bfit, key = "FakeID", allow.cartesian = TRUE)
    SimbDT <- data.table(Simb, key = "FakeID", allow.cartesian = TRUE)
    SimbCombDT <- SimbDT[bfitDT, allow.cartesian = TRUE]
    Simb <- data.frame(SimbCombDT)
    Simb$QI <- Simb$hazard * Simb$HR
  }

  # Drop simulations outside of 'confidence bounds'
  if (qi != "Hazard Rate"){
  	SubVar <- "Xj"
  } else if (qi == "Hazard Rate"){
  	SubVar <- c("time", "Xj")
  }

  SimbPerc <- IntervalConstrict(Simb = Simb, SubVar = SubVar, qi = qi,
                                QI = QI, spin = spin, ci = ci)

  # Final clean up
  class(SimbPerc) <- c("simlinear", qi)
  SimbPerc
}