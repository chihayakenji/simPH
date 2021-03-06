#' Plot simulated penalised spline hazards from Cox Proportional Hazards Models
#'
#' \code{simGG.simspline} uses \link{ggplot2} and \link{scatter3d} to plot quantities of interest from \code{simspline} objects, including relative hazards, first differences, hazard ratios, and hazard rates.
#'
#' @param obj a \code{simspline} class object
#' @param FacetTime a numeric vector of points in time where you would like to plot Hazard Rates in a facet grid. Only relevant if \code{qi == 'Hazard Rate'}. Note: the values of Facet Time must exactly match values of the \code{time} element of \code{obj}.
#' @param xlab a label for the plot's x-axis.
#' @param ylab a label of the plot's y-axis. The default uses the value of \code{qi}.
#' @param zlab a label for the plot's z-axis. Only relevant if \code{qi = "Hazard Rate"} and \code{FacetTime == NULL}.
#' @param from numeric time to start the plot from. Only relevant if \code{qi = "Hazard Rate"}.
#' @param to numeric time to plot to. Only relevant if \code{qi = "Hazard Rate"}.
#' @param title the plot's main title.
#' @param smoother what type of smoothing line to use to summarize the plotted coefficient.
#' @param leg.name name of the stratified hazard rates legend. Only relevant if \code{qi = "Hazard Rate"}.
#' @param lcolour character string colour of the smoothing line. The default is hexadecimal colour \code{lcolour = '#2B8CBE'}. Only relevant if \code{qi = "Relative Hazard"} or \code{qi = "First Difference"}.
#' @param lsize size of the smoothing line. Default is 2. See \code{\link{ggplot2}}.
#' @param pcolour character string colour of the simulated points for relative hazards. Default is hexadecimal colour \code{pcolour = '#A6CEE3'}. Only relevant if \code{qi = "Relative Hazard"} or \code{qi = "First Difference"}.
#' @param psize size of the plotted simulation points. Default is \code{psize = 1}. See \code{\link{ggplot2}}.
#' @param palpha point alpha (e.g. transparency). Default is \code{palpha = 0.05}. See \code{\link{ggplot2}}.
#' @param surface plot surface. Default is \code{surface = TRUE}. Only relevant if \code{qi == 'Relative Hazard'} and \code{FacetTime = NULL}.
#' @param fit one or more of \code{"linear"}, \code{"quadratic"}, \code{"smooth"}, \code{"additive"}; to display fitted surface(s); partial matching is supported e.g., \code{c("lin", "quad")}. Only relevant if \code{qi == 'Relative Hazard'} and \code{FacetTime = NULL}.
#' @param ... Additional arguments. (Currently ignored.)
#'
#' @return a \code{gg} \code{ggplot} class object. See \code{\link{scatter3d}} for values from \code{scatter3d} calls.
#'  
#' @details Uses \code{ggplot2} and \code{scatter3d} to plot the quantities of interest from \code{simspline} objects, including relative hazards, first differences, hazard ratios, and hazard rates. If currently does not support hazard rates for multiple strata.
#'
#' It can graph hazard rates as a 3D plot using \code{\link{scatter3d}} with the dimensions: Time, Hazard Rate, and the value of \code{Xj}. You can also choose to plot hazard rates for a range of values of \code{Xj} in two dimensional plots at specific points in time. Each plot is arranged in a facet grid.
#'
#' Note: A dotted line is created at y = 1 (0 for first difference), i.e. no effect, for time-varying hazard ratio graphs. No line is created for hazard rates.
#'
#' @examples
#' ## dontrun
#' # Load Carpenter (2002) data
#' # data("CarpenterFdaData")
#' 
#' # Load survival package
#' # library(survival)
#' 
#' # Run basic model
#' # From Keele (2010) replication data
#' # M1 <- coxph(Surv(acttime, censor) ~  prevgenx + lethal + deathrt1 + 
#' #				acutediz + hosp01  + pspline(hospdisc, df = 4) + 
#' #				pspline(hhosleng, df = 4) + mandiz01 + femdiz01 + peddiz01 +
#' #				orphdum + natreg + vandavg3 + wpnoavg3 + 
#' #				pspline(condavg3, df = 4) + pspline(orderent, df = 4) + 
#' #				pspline(stafcder, df = 4), data = CarpenterFdaData)
#'
#' # Simulate Relative Hazards for orderent
#' # Sim1 <- coxsimSpline(M1, bspline = "pspline(stafcder, df = 4)", 
#' #                    bdata = CarpenterFdaData$stafcder,
#' #                    qi = "Hazard Ratio",
#' #                    Xj = seq(1100, 1700, by = 10), 
#' #                    Xl = seq(1099, 1699, by = 10), spin = TRUE)
#'
#' # Simulate Hazard Rate for orderent
#' # Sim2 <- coxsimSpline(M1, bspline = "pspline(orderent, df = 4)",
#' #                    bdata = CarpenterFdaData$orderent,
#' #                    qi = "Hazard Rate",
#' #                    Xj = seq(1, 30, by = 2), ci = 0.9, nsim = 10)  
#'                        
#' # Plot relative hazard
#' # simGG(Sim1, palpha = 1)
#' 
#' # 3D plot hazard rate
#' # simGG(Sim2, zlab = "orderent", fit = "quadratic")
#'
#' # Create a time grid plot
#' # Find all points in time where baseline hazard was found
#' # unique(Sim2$time)
#' 
#' # Round time values so they can be exactly matched with FacetTime
#' # Sim2$time <- round(Sim2$time, digits = 2)
#' 
#' # Create plot
#' # simGG(Sim2, FacetTime = c(6.21, 25.68, 100.64, 202.36))
#'
#' # Simulated Fitted Values of stafcder
#' # Sim3 <- coxsimSpline(M1, bspline = "pspline(stafcder, df = 4)", 
#' #                    bdata = CarpenterFdaData$stafcder,
#' #                    qi = "Hazard Ratio",
#' #                    Xj = seq(1100, 1700, by = 10), 
#' #                    Xl = seq(1099, 1699, by = 10), ci = 0.90)
#'
#' # Plot simulated Hazard Ratios
#' # simGG(Sim3, xlab = "\nFDA Drug Review Staff", palpha = 0.2)
#' 
#' @seealso \code{\link{coxsimLinear}}, \code{\link{simGG.simtvc}},  \code{\link{ggplot2}}, and \code{\link{scatter3d}} 
#' 
#' 
#' 
#' 
#' @import ggplot2 
#' @importFrom car scatter3d
#' @method simGG simspline
#' @S3method simGG simspline

simGG.simspline <- function(obj, FacetTime = NULL, from = NULL, to = NULL, xlab = NULL, ylab = NULL, zlab = NULL, title = NULL, smoother = "auto", leg.name = "", lcolour = "#2B8CBE", lsize = 2, pcolour = "#A6CEE3", psize = 1, palpha = 0.1, surface = TRUE, fit = "linear", ...)
{
	Time <- Xj <- QI <- NULL
	if (!inherits(obj, "simspline")){
    	stop("must be a simspline object")
    }
    # Find quantity of interest
    qi <- class(obj)[[2]]

    # Create y-axis label
    if (is.null(ylab)){
    	ylab <- paste(qi, "\n")
    } else {
    	ylab <- ylab
    }
    # Subset simspline object & create a data frame of important variables
	if (qi == "Hazard Rate"){
		spallette <- NULL
		if (is.null(obj$strata)){
			objdf <- data.frame(obj$time, obj$QI, obj$Xj)
			names(objdf) <- c("Time", "QI", "Xj")
		} 
		# Currently does not support strata
		#else if (!is.null(obj$strata)) {
		#objdf <- data.frame(obj$time, obj$HRate, obj$strata, obj$Xj)
		#names(objdf) <- c("Time", "HRate", "Strata", "Xj")
		#}
		if (!is.null(from)){
			objdf <- subset(objdf, Time >= from)
  		}
  		if (!is.null(to)){
  			objdf <- subset(objdf, Time <= to)
  		}
	} else if (qi == "Hazard Ratio"){
	  	objdf <- data.frame(obj$Xj, obj$QI, obj$Comparison)
	  	names(objdf) <- c("Xj", "QI", "Comparison")
	} else if (qi == "Relative Hazard"){
	  	objdf <- data.frame(obj$Xj, obj$QI)
	  	names(objdf) <- c("Xj", "QI")
	} else if (qi == "First Difference"){
		objdf <- data.frame(obj$Xj, obj$QI, obj$Comparison)
		names(objdf) <- c("Xj", "QI", "Comparison")
	}

	# Plots
	if (qi == "Relative Hazard"){
		ggplot(objdf, aes(Xj, QI)) +
		    geom_point(shape = 21, alpha = I(palpha), size = psize, colour = pcolour) +
	        geom_smooth(method = smoother, size = lsize, se = FALSE, color = lcolour) +
		    geom_hline(aes(yintercept = 1), linetype = "dotted") +
		    xlab(xlab) + ylab(ylab) +
		    ggtitle(title) +
		    guides(colour = guide_legend(override.aes = list(alpha = 1))) +
		    theme_bw(base_size = 15)
	} else if (qi == "First Difference"){
    	ggplot(objdf, aes(Xj, QI)) +
        	geom_point(shape = 21, alpha = I(palpha), size = psize, colour = pcolour) +
	        geom_smooth(method = smoother, size = lsize, se = FALSE, color = lcolour) +
	        geom_hline(aes(yintercept = 0), linetype = "dotted") +
	        xlab(xlab) + ylab(ylab) +
	        ggtitle(title) +
	        guides(colour = guide_legend(override.aes = list(alpha = 1))) +
	        theme_bw(base_size = 15)
	} else if (qi == "Hazard Ratio"){
		ggplot(objdf, aes(Xj, QI)) +
	        geom_point(shape = 21, alpha = I(palpha), size = psize, colour = pcolour) +
	        geom_smooth(method = smoother, size = lsize, se = FALSE, color = lcolour) +
	        geom_hline(aes(yintercept = 1), linetype = "dotted") +
	        xlab(xlab) + ylab(ylab) +
	        ggtitle(title) +
	        guides(colour = guide_legend(override.aes = list(alpha = 1))) +
	        theme_bw(base_size = 15)
    } else if (qi == "Hazard Rate" & is.null(FacetTime)){
    	with(objdf, scatter3d(x = Time, y = QI, z = Xj,
    						  xlab = xlab, ylab = ylab, zlab = zlab,
    						  surface = surface,
    						  fit = fit))
    } else if (qi == "Hazard Rate" & !is.null(FacetTime)){
		SubsetTime <- function(f){
		  Time <- NULL
		  CombObjdf <- data.frame()
		  for (i in f){
		    Temps <- objdf
		    TempsSub <- subset(Temps, Time == i)
		    CombObjdf <- rbind(CombObjdf, TempsSub)
		  }
		  CombObjdf
		}
		objdfSub <- SubsetTime(FacetTime)
		ggplot(objdfSub, aes(Xj, QI)) +
	        geom_point(shape = 21, alpha = I(palpha), size = psize, colour = pcolour) +
	        geom_smooth(method = smoother, size = lsize, se = FALSE, color = lcolour) +
	        facet_grid(.~Time) +
	        xlab(xlab) + ylab(ylab) +
	        ggtitle(title) +
	        guides(colour = guide_legend(override.aes = list(alpha = 1))) +
	        theme_bw(base_size = 15)
    }
}