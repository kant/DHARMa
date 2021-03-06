#' DHARMa standard residual plots
#' 
#' This function creates standard plots for the simulated residuals
#' @param x an object with simualted residuals created by \code{\link{simulateResiduals}}
#' @param rank if T (default), the values of pred will be rank transformed. This will usually make patterns easier to spot visually, especially if the distribution of the predictor is skewed. 
#' @param ... further options for \code{\link{plotResiduals}}. Consider in particular parameters quantreg, rank and asFactor. xlab, ylab and main cannot be changed when using plotSimulatedResiduals, but can be changed when using plotResiduals.
#' @details The function creates two plots. To the left, a qq-uniform plot to detect deviations from overall uniformity of the residuals (calling \code{\link{plotQQunif}}), and to the right, a plot of residuals against predicted values (calling \code{\link{plotResiduals}}). Outliers are highlighted in red (for more on oultiers, see \code{\link{testOutliers}}). For a correctly specified model, we would expect 
#' 
#' a) a straight 1-1 line in the uniform qq-plot -> evidence for an overal uniform (flat) distribution of the residuals
#' 
#' b) uniformity of residuals in the vertical direction in the res against predictor plot
#' 
#' Deviations of this can be interpreted as for a linear regression. See the vignette for detailed examples. 
#' 
#' To provide a visual aid in detecting deviations from uniformity in y-direction, the plot of the residuals against the predited values also performs an (optional) quantile regression, which provides 0.25, 0.5 and 0.75 quantile lines across the plots. These lines should be straight, horizontal, and at y-values of 0.25, 0.5 and 0.75. Note, however, that some deviations from this are to be expected by chance, even for a perfect model, especially if the sample size is small. See further comments on this plot, it's interpreation and options, in \code{\link{plotResiduals}}
#' 
#' The quantile regression can take some time to calculate, especially for larger datasets. For that reason, quantreg = F can be set to produce a smooth spline instead. This is default for n > 2000. 
#' 
#' @seealso \code{\link{plotResiduals}}, \code{\link{plotQQunif}}
#' @example inst/examples/plotsHelp.R
#' @import graphics
#' @import utils
#' @export
plot.DHARMa <- function(x, rank = TRUE, ...){
  
  oldpar <- par(mfrow = c(1,2), oma = c(0,1,2,1))
  
  plotQQunif(x)
  
  xlab = checkDots("xlab", ifelse(rank, "Model predictions (rank transformed)", "Model predictions"), ...)

  plotResiduals(simulationOutput = x, xlab = xlab, rank = rank, ...)
  
  mtext("DHARMa residual diagnostics", outer = T)
  
  par(oldpar)
}


#' Histogram of DHARMa residuals
#' 
#' The function produces a histogram from a DHARMa output
#' 
#' @param x a DHARMa simulation output (class DHARMa)
#' @param breaks breaks for hist() function
#' @param col col for hist bars
#' @param main plot main
#' @param xlab plot xlab
#' @param cex.main plot cex.main
#' @param ... other arguments to be passed on to hist
#' @seealso \code{\link{plotSimulatedResiduals}}, \code{\link{plotResiduals}}
#' @example inst/examples/plotsHelp.R
#' @export
hist.DHARMa <- function(x, 
                        breaks = seq(-0.02, 1.02, len = 53), 
                        col = c("red",rep("lightgrey",50), "red"),
                        main = "Hist of DHARMa residuals",
                        xlab = "Residuals (outliers are marked red)",
                        cex.main = 1,
                        ...){
  
  x = ensureDHARMa(x, convert = T)
  
  val = x$scaledResiduals
  val[val == 0] = -0.01
  val[val == 1] = 1.01

  hist(val, breaks = breaks, col = col, main = main, xlab = xlab, cex.main = cex.main, ...)
}


#' DHARMa standard residual plots
#' 
#' DEPRECATED, use plot() instead
#' 
#' @param simulationOutput an object with simualted residuals created by \code{\link{simulateResiduals}}
#' @param ... further options for \code{\link{plotResiduals}}. Consider in particular parameters quantreg, rank and asFactor. xlab, ylab and main cannot be changed when using plotSimulatedResiduals, but can be changed when using plotResiduals.
#' @note This function is deprecated. Use \code{\link{plot.DHARMa}}
#' 
#' @seealso \code{\link{plotResiduals}}, \code{\link{plotQQunif}}
#' @export
plotSimulatedResiduals <- function(simulationOutput, ...){
  message("plotSimulatedResiduals is deprecated, switch your code to using the plot function")
  plot(simulationOutput, ...)
}


#' Quantile-quantile plot for a uniform distribution
#' 
#' The function produces a uniform quantile-quantile plot from a DHARMa output
#' 
#' @param simulationOutput a DHARMa simulation output (class DHARMa)
#' @param testUniformity if T, the function \code{\link{testUniformity}} will be called and the result will be added to the plot
#' @param testOutliers if T, the function \code{\link{testOutliers}} will be called and the result will be added to the plot
#' @param testDispersion if T, the function \code{\link{testDispersion}} will be called and the result will be added to the plot
#' @param ... arguments to be passed on to \code{\link[gap]{qqunif}}
#' 
#' @details the function calls qqunif from the R package gap to create a quantile-quantile plot for a uniform distribution.  
#' @seealso \code{\link{plotSimulatedResiduals}}, \code{\link{plotResiduals}}
#' @example inst/examples/plotsHelp.R
#' @export
plotQQunif <- function(simulationOutput, testUniformity = T, testOutliers = T, testDispersion = T, ...){
  
  simulationOutput = ensureDHARMa(simulationOutput, convert = "Model")

  gap::qqunif(simulationOutput$scaledResiduals,pch=2,bty="n", logscale = F, col = "black", cex = 0.6, main = "QQ plot residuals", cex.main = 1, ...)
  
  if(testUniformity == TRUE){
    temp = testUniformity(simulationOutput, plot = F)
    legend("topleft", c(paste("KS test: p=", round(temp$p.value, digits = 5)), paste("Deviation ", ifelse(temp$p.value < 0.05, "significant", "n.s."))), text.col = ifelse(temp$p.value < 0.05, "red", "black" ), bty="n")     
  }
  
  if(testOutliers == TRUE){
    temp = testOutliers(simulationOutput, plot = F)
    legend("bottomright", c(paste("Outlier test: p=", round(temp$p.value, digits = 5)), paste("Deviation ", ifelse(temp$p.value < 0.05, "significant", "n.s."))), text.col = ifelse(temp$p.value < 0.05, "red", "black" ), bty="n")     
  }
  
  if(testDispersion == TRUE){
    temp = testDispersion(simulationOutput, plot = F)
    legend("center", c(paste("Dispersion test: p=", round(temp$p.value, digits = 5)), paste("Deviation ", ifelse(temp$p.value < 0.05, "significant", "n.s."))), text.col = ifelse(temp$p.value < 0.05, "red", "black" ), bty="n")     
  }
  
}


#' Generic residual plot with either spline or quantile regression
#' 
#' The function creates a generic residual plot with either spline or quantile regression to highlight patterns in the residuals. Outliers are highlighted in red
#' 
#' @param simulationOutput usually a DHARMa object, from which residual values can be extracted. Alternatively, a vector with residuals or a fitted model can be provided, which will then be transformed into a DHARMa object
#' @param predictor either the predictor variable against which the residuals should be plotted, or a DHARMa object, in which case res ~ pred is plotted
#' @param quantreg whether to perform a quantile regression on 0.25, 0.5, 0.75 on the residuals. If F, a spline will be created instead. Default NULL chooses T for nObs < 2000, and F otherwise. 
#' @param rank if T, the values of pred will be rank transformed. This will usually make patterns easier to spot visually, especially if the distribution of the predictor is skewed. If pred is a factor, this has no effect. 
#' @param asFactor should a numeric predictor be treated as a factor. Default is to choose this for < 10 unique predictions, as long as enough predictions are available to draw a boxplot.
#' @param smoothScatter if T, a smooth scatter plot will plotted instead of a normal scatter plot. This makes sense when the number of residuals is very large. Default NULL chooses T for nObs < 10000, and F otherwise.
#' @param quantiles for a quantile regression, which quanties should be plotted 
#' @param ... additional arguments to plot / boxplot. 
#' @details The function plots residuals against a predictor (by default against the fitted value, extracted from the DHARMa object, or any other predictor). 
#' 
#' Outliers are highlighted in red (for information on definition and interpretation of outliers, see \code{\link{testOutliers}}). 
#' 
#' To provide a visual aid in detecting deviations from uniformity in y-direction, the plot function calculates an (optional) quantile regression, which compares the empirical 0.25, 0.5 and 0.75 quantiles (default) in y direction (red solid lines) with the theoretical 0.25, 0.5 and 0.75 quantiles (dashed black line). 
#' 
#' Assymptotically (i.e. for lots of data / residuals), if the model is correct, theoretical and the empirical quantiles should be identical (i.e. dashed and solid lines should match). A p-value for the deviation is calculated for each quantile line. Significant deviations are highlighted by red color. 
#' 
#' If pred is a factor, a boxplot will be plotted instead of a scatter plot. The distribution for each factor level should be uniformly distributed, so the box should go from 0.25 to 0.75, with the median line at 0.5. Again, chance deviations from this will increases when the sample size is smaller. You can run null simulations to test if the deviations you see exceed what you would expect from random variation. If you want to create box plots for categorical predictors (e.g. because you only have a small number of unique numberic predictor values), you can convert your predictor with as.factor(pred)
#' 
#' @note The quantile regression can take some time to calculate, especially for larger datasets. For that reason, quantreg = F can be set to produce a smooth spline instead. 
#' 
#' @seealso \code{\link{plotQQunif}}
#' @example inst/examples/plotsHelp.R
#' @export
plotResiduals <- function(simulationOutput, predictor = NULL, quantreg = NULL, rank = F, asFactor = NULL, smoothScatter = NULL, quantiles = c(0.25, 0.5, 0.75), ...){
  
  
  ##### Checks #####
  
  ylab = checkDots("ylab", "Standardized residual", ...)
  
  simulationOutput = ensureDHARMa(simulationOutput, convert = T)
  res = simulationOutput$scaledResiduals
  pred = ensurePredictor(simulationOutput, predictor)
  
  ##### Rank transform and factor conversion#####
  
  if(!is.factor(pred)){

    if (rank == T){
      pred = rank(pred, ties.method = "average")
      pred = pred / max(pred)          
    } 
        
    nuniq = length(unique(pred))
    ndata = length(pred)  
    if(is.null(asFactor)) asFactor = (nuniq == 1) | (nuniq < 10 & ndata / nuniq > 10)
    if (asFactor) pred = factor(pred)
  }

  ##### Residual scatter plots #####
  
  if(is.null(quantreg)) if (length(res) > 2000) quantreg = FALSE else quantreg = TRUE
  
  switchScatter = 10000
  if(is.null(smoothScatter)) if (length(res) > switchScatter) smoothScatter = TRUE else smoothScatter = FALSE

  blackcol = rgb(0,0,0, alpha = max(0.1, 1 - 3 * length(res) / switchScatter))
  
  defaultCol = ifelse(res == 0 | res == 1, 2,blackcol)
  defaultPch = ifelse(res == 0 | res == 1, 8,1)   

  col = checkDots("col", defaultCol, ...)
  pch = checkDots("pch", defaultPch, ...)
  
  if(is.factor(pred)){
    plot(res ~ pred, ylim = c(0,1), axes = FALSE, ...)
  } 
  else if (smoothScatter == TRUE) {
    smoothScatter(pred, res , ylim = c(0,1), axes = FALSE, colramp = colorRampPalette(c("white", "darkgrey")))
    points(pred[defaultCol == 2], res[defaultCol == 2], col = "red", cex = 0.5)
  }
  else{
    plot(res ~ pred, ylim = c(0,1), axes = FALSE, col = col, pch = pch, ylab = ylab, ...)
  } 
  
  axis(1)
  axis(2, at=c(0, 0.25, 0.5, 0.75, 1))
  
  ##### Quantile regressions #####
  
  main = checkDots("main", "Residual vs. predicted", ...)
  out = NULL
  
  if(is.numeric(pred)){
    if(quantreg == F){
      title(main = main, cex.main = 1)
      abline(h = c(0.25, 0.5, 0.75), col = "black", lwd = 0.5, lty = 2)
      try({
        lines(smooth.spline(pred, res, df = 10), lty = 2, lwd = 2, col = "red")
        abline(h = 0.5, col = "red", lwd = 2)
      }, silent = T)
    }else{
      
      out = testQuantiles(simulationOutput, pred, quantiles = quantiles, plot = F)
      
      if(any(out$pvals < 0.05)){
        main = paste(main, "Quantile deviations detected (red curves)", sep ="\n")
        if(out$p.value <= 0.05){
          main = paste(main, "Combined adjusted quantile test signficant", sep ="\n")
        } else {
          main = paste(main, "Combined adjusted quantile test n.s.", sep ="\n")
        }
        maincol = "red"
      } else {
        main = paste(main, "No signficiant problems detected", sep ="\n")
        maincol = "black"
      }
      
      title(main = main, cex.main = 0.8, 
            col.main = maincol)
      
      for(i in 1:length(quantiles)){
        
        lineCol = ifelse(out$pvals[i] <= 0.05, "red", "black")
        filCol = ifelse(out$pvals[i] <= 0.05, "#FF000040", "#00000020")
        
        abline(h = quantiles[i], col = lineCol, lwd = 0.5, lty = 2)
        polygon(c(out$predictions$pred, rev(out$predictions$pred)),
                c(out$predictions[,2*i] - out$predictions[,2*i+1], rev(out$predictions[,2*i] + out$predictions[,2*i+1])), 
                col = "#00000020", border = F)
        lines(out$predictions$pred, out$predictions[,2*i], col = lineCol, lwd = 2)
      }
      
      # legend("bottomright", c(paste("Quantile test: p=", round(out$p.value, digits = 5)), paste("Deviation ", ifelse(out$p.value < 0.05, "significant", "n.s."))), text.col = ifelse(out$p.value < 0.05, "red", "black" ), bty="n")  
      
    }
  }
  return(out)
}



#plot(simulationOutput)

#plot(simulationOutput$observedResponse, simulationOutput$scaledResiduals, xlab = "predicted", ylab = "Residual", main = "Residual vs. predicted")

#plot(simulationOutput$observedResponse, simulationOutput$fittedPredictedResponse - simulationOutput$observedResponse)

#plot(cumsum(sort(simulationOutput$scaledResiduals)))


#plotConcentionalResiduals(fittedModel)


#' Conventional residual plot
#' 
#' Convenience function to draw conventional residual plots
#' 
#' @param fittedModel a fitted model object
#' @export
plotConventionalResiduals <- function(fittedModel){
  par(mfrow = c(1,3), oma = c(0,1,2,1))
  plot(predict(fittedModel), resid(fittedModel, type = "deviance"), main = "Deviance" , ylab = "Residual", xlab = "Predicted")
  plot(predict(fittedModel), resid(fittedModel, type = "pearson") , main = "Pearson", ylab = "Residual", xlab = "Predicted")
  plot(predict(fittedModel), resid(fittedModel, type = "response") , main = "Raw residuals" , ylab = "Residual", xlab = "Predicted")  
  mtext("Conventional residual plots", outer = T)
}




# 
# 
# if(quantreg == F){
#   
#   lines(smooth.spline(simulationOutput$fittedPredictedResponse, simulationOutput$scaledResiduals, df = 10), lty = 2, lwd = 2, col = "red")
#   
#   abline(h = 0.5, col = "red", lwd = 2)
#   
# }else{
#   
#   #library(gamlss)
#   
#   # qrnn
#   
#   # http://r.789695.n4.nabble.com/Quantile-GAM-td894280.html
#   
#   #require(quantreg)
#   #dat <- plyr::arrange(dat,pred)
#   #fit<-quantreg::rqss(resid~qss(pred,constraint="N"),tau=0.5,data = dat)
#   
#   probs = c(0.25, 0.50, 0.75)
#   
#   w <- p <- list()
#   for(i in seq_along(probs)){
#     capture.output(w[[i]] <- qrnn::qrnn.fit(x = as.matrix(simulationOutput$fittedPredictedResponse), y = as.matrix(simulationOutput$scaledResiduals), n.hidden = 4, tau = probs[i], iter.max = 1000, n.trials = 1, penalty = 1))
#     p[[i]] <- qrnn::qrnn.predict(as.matrix(sort(simulationOutput$fittedPredictedResponse)), w[[i]])
#   }
#   
#   
#   
#   #plot(simulationOutput$fittedPredictedResponse, simulationOutput$scaledResiduals, xlab = "Predicted", ylab = "Residual", main = "Residual vs. predicted\n lines should match", cex.main = 1)
#   
#   #lines(sort(simulationOutput$fittedPredictedResponse), as.vector(p[[1]]), col = "red")
#   
#   matlines(sort(simulationOutput$fittedPredictedResponse), matrix(unlist(p), nrow = length(simulationOutput$fittedPredictedResponse), ncol = length(p)), col = "red", lty = 1)
#   
#   #     as.vector(p[[1]])
#   #     
#   #     
#   #     lines(simulationOutput$fittedPredictedResponse,p[[1]], col = "red", lwd = 2)
#   #     abline(h = 0.5, col = "red", lwd = 2)
#   #     
#   #     fit<-quantreg::rqss(resid~qss(pred,constraint="N"),tau=0.25,data = dat)
#   #     lines(unique(dat$pred)[-1],fit$coef[1] + fit$coef[-1], col = "green", lwd = 2, lty =2)
#   #     abline(h = 0.25, col = "green", lwd = 2, lty =2)
#   #     
#   #     fit<-quantreg::rqss(resid~qss(pred,constraint="N"),tau=0.75,data = dat)
#   #     lines(unique(dat$pred)[-1],fit$coef[1] + fit$coef[-1], col = "blue", lwd = 2, lty = 2)
#   #     abline(h = 0.75, col = "blue", lwd = 2, lty =2)   
# }

