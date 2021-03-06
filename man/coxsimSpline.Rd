\name{coxsimSpline}
\alias{coxsimSpline}
\title{Simulate quantities of interest for penalized splines from Cox Proportional Hazards models}
\usage{
  coxsimSpline(obj, bspline, bdata, qi = "Relative Hazard",
    Xj = 1, Xl = 0, nsim = 1000, ci = 0.95, spin = FALSE)
}
\arguments{
  \item{obj}{a \code{\link{coxph}} class fitted model
  object with a penalized spline. These can be plotted with
  \code{\link{simGG}}.}

  \item{bspline}{a character string of the full
  \code{\link{pspline}} call used in \code{obj}. It should
  be exactly the same as how you entered it in
  \code{\link{coxph}}. You also need to enter a white spece
  before and after all equal (\code{=}) signs.}

  \item{bdata}{a numeric vector of splined variable's
  values.}

  \item{qi}{quantity of interest to simulate. Values can be
  \code{"Relative Hazard"}, \code{"First Difference"},
  \code{"Hazard Ratio"}, and \code{"Hazard Rate"}. The
  default is \code{qi = "Relative Hazard"}. Think carefully
  before using \code{qi = "Hazard Rate"}. You may be
  creating very many simulated values which can be very
  computationally intensive to do. Adjust the number of
  simulations per fitted value with \code{nsim}.}

  \item{Xj}{numeric vector of fitted values for \code{b} to
  simulate for.}

  \item{Xl}{numeric vector of values to compare \code{Xj}
  to. Note if \code{qi = "Relative Hazard"} or
  \code{"Hazard Rate"} only \code{Xj} is relevant.}

  \item{nsim}{the number of simulations to run per value of
  \code{Xj}. Default is \code{nsim = 1000}.}

  \item{ci}{the proportion of simulations to keep. The
  default is \code{ci = 0.95}, i.e. keep the middle 95
  percent. If \code{spin = TRUE} then \code{ci} is the
  confidence level of the shortest probability interval.
  Any value from 0 through 1 may be used.}

  \item{spin}{logical, whether or not to keep only the
  shortest probability interval rather than the middle
  simulations.}
}
\value{
  a \code{simspline} object
}
\description{
  \code{coxsimSpline} simulates quantities of interest from
  penalized splines using multivariate normal
  distributions.
}
\details{
  Simulates relative hazards, first differences, hazard
  ratios, and hazard rates for penalized splines from Cox
  Proportional Hazards models. These can be plotted with
  \code{\link{simGG}}. A Cox PH model with one penalized
  spline is given by:
  \deqn{h(t|\mathbf{X}_{i})=h_{0}(t)\mathrm{e}^{g(x)}}

  where \eqn{g(x)} is the penalized spline function. For
  our post-estimation purposes \eqn{g(x)} is basically a
  series of linearly combined coefficients such that:

  \deqn{g(x) = \beta_{k_{1}}(x)_{1+} +
  \beta_{k_{2}}(x)_{2+} + \beta_{k_{3}}(x)_{3+} + \ldots +
  \beta_{k_{n}}(x)_{n+}}

  where \eqn{k} are the equally spaced spline knots with
  values inside of the range of observed \eqn{x} and
  \eqn{n} is the number of knots.

  We can again draw values of each \eqn{\beta_{k_{1}},
  \ldots \beta_{k_{n}}} from the multivariate normal
  distribution described above. We then use these simulated
  coefficients to estimates quantities of interest for a
  range covariate values. For example, the first difference
  between two values \eqn{x_{j}} and \eqn{x_{l}} is:

  \deqn{\%\triangle h_{i}(t) = (\mathrm{e}^{g(x_{j}) -
  g(x_{l})} - 1) * 100}

  Relative hazards and hazard ratios can be calculated by
  extension.

  Currently \code{coxsimSpline} does not support simulating
  hazard rates form multiple stratified models.
}
\examples{
## dontrun
# Load Carpenter (2002) data
# data("CarpenterFdaData")

# Load survival package
# library(survival)

# Run basic model
# From Keele (2010) replication data
# M1 <- coxph(Surv(acttime, censor) ~  prevgenx + lethal + deathrt1 +
#				acutediz + hosp01  + pspline(hospdisc, df = 4) +
#				pspline(hhosleng, df = 4) + mandiz01 + femdiz01 + peddiz01 +
#				orphdum + natreg + vandavg3 + wpnoavg3 +
#				pspline(condavg3, df = 4) + pspline(orderent, df = 4) +
#				pspline(stafcder, df = 4), data = CarpenterFdaData)

# Simulate Relative Hazards for orderent
# Sim1 <- coxsimSpline(M1, bspline = "pspline(stafcder, df = 4)",
#                    bdata = CarpenterFdaData$stafcder,
#                    qi = "Hazard Ratio",
#                    Xj = seq(1100, 1700, by = 10),
#                    Xl = seq(1099, 1699, by = 10), spin = TRUE)

## dontrun
# Simulate Hazard Rates for orderent
# Sim2 <- coxsimSpline(M1, bspline = "pspline(orderent, df = 4)",
#                       bdata = CarpenterFdaData$orderent,
#                       qi = "Hazard Rate",
#                       Xj = seq(2, 53, by = 3),
#                       nsim = 100)
}
\references{
  Luke Keele, "Replication data for: Proportionally
  Difficult: Testing for Nonproportional Hazards In Cox
  Models", 2010, \url{http://hdl.handle.net/1902.1/17068}
  V1 [Version].

  King, Gary, Michael Tomz, and Jason Wittenberg. 2000.
  ''Making the Most of Statistical Analyses: Improving
  Interpretation and Presentation.'' American Journal of
  Political Science 44(2): 347-61.

  Liu, Ying, Andrew Gelman, and Tian Zheng. 2013.
  ''Simulation-Efficient Shortest Probability Intervals.''
  Arvix. \url{http://arxiv.org/pdf/1302.2142v1.pdf}.
}
\seealso{
  \code{\link{simGG}}, \code{\link{survival}},
  \code{\link{strata}}, and \code{\link{coxph}}
}

