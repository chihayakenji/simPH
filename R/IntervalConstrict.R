#' Constrict simulations to a defined interval.
#'
#' \code{IntervalConstrict} is an internal function to constrict a set of simulations to user defined interval.
#'
#' @param Simb character string naming the data frame with the simulations.
#' @param SubVar character vector the variable names to subset the simulations by.
#' @param qi character vector naming the type of quantity of interest.
#' @param QI character string labeling the quantitiy of interest values.
#' @param spin logical for whether or not to use the shortest probability interval or the central interval.
#' @param ci numeric confidence interval measure.
#' 
#' @importFrom plyr ddply mutate
#' @export

IntervalConstrict <- function(Simb = Simb, SubVar = SubVar, qi = qi, QI = QI, spin = FALSE, ci = 0.95)
{
	if (qi != "First Difference" |qi != "Marginal Effect"){
		lb <- 0
	} 
	else if (qi == "First Difference"){
		lb <- -100
	} 
	else if (qi == "Marginal Effect"){
		lb <- -Inf
	}

	if (!isTRUE(spin))
	{
		Bottom <- (1 - ci)/2
		Top <- 1 - Bottom
		SimbPerc <- eval(parse(text = paste0("ddply(Simb, SubVar, mutate, Lower = QI < quantile(QI,", Bottom, "))")))
		SimbPerc <- eval(parse(text = paste0("ddply(SimbPerc, SubVar, mutate, Upper = QI > quantile(QI,", Top, "))" )))
	}

	# Drop simulations outside of the shortest probability interval
	else if (isTRUE(spin))
	{
		SimbPerc <- eval(parse(text = paste0("ddply(Simb, SubVar, mutate, Lower = QI < SpinBounds(QI, conf = ", ci, ", lb = ", lb, ", LowUp = 1))" )))
		SimbPerc <- eval(parse(text = paste0("ddply(SimbPerc, SubVar, mutate, Upper = QI > SpinBounds(QI, conf = ", ci, ", lb = ", lb, ", LowUp = 2))" )))
	}

	SimbPerc <- subset(SimbPerc, Lower == FALSE & Upper == FALSE)
	return(SimbPerc)
}