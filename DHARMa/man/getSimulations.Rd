% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compatibility.R
\name{getSimulations}
\alias{getSimulations}
\title{Get model simulations}
\usage{
getSimulations(object, ...)
}
\arguments{
\item{object}{a fitted model}

\item{...}{additional parameters to be passed on, usually to the simulate function of the respective model class}
}
\description{
Wrapper to simulate from a fitted model
}
\details{
The purpose of this wrapper for for the simulate function is to standardize the simulations from a model in a standardized way
}
\author{
Florian Hartig
}
