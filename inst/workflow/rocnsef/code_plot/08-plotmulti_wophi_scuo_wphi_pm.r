### This script plots comparisions across cases.

rm(list = ls())

library(cubfits)

source("00-set_env.r")
source(paste(prefix$code.plot, "u0-get_case_main.r", sep = ""))
source(paste(prefix$code, "u1-get_negsel.r", sep = ""))
source(paste(prefix$code.plot, "u2-plot_b_corr.r", sep = ""))
source(paste(prefix$code.plot, "u5-new_page.r", sep = ""))

if(length(case.names) < 4){
  stop("Need 4 cases to match with.")
}
case.main <- "wophi_scuo_wphi_pm"

# Load data.
fn.in <- paste(prefix$data, "pre_process.rda", sep = "")
load(fn.in)

# Get AA and synonymous codons.
aa.names <- names(reu13.df.obs)
label <- NULL
for(i.aa in aa.names){
  tmp <- sort(unique(reu13.df.obs[[i.aa]]$Codon))
  tmp <- tmp[-length(tmp)]
  label <- c(label, paste(i.aa, tmp, sep = "."))
}

# Ordered by "ad_wophi_pm", "ad_wophi_scuo", "ad_wphi_pm", and "ad_wphi_scuo".
# Only "ad_wophi_scuo" and "ad_wphi_pm" are used.
phi.pm <- list()
phi.median <- list()
phi.ci <- list()
phi.pm.log10 <- list()
phi.std.log10 <- list()
phi.ci.log10 <- list()
b.pm <- list()
b.ci <- list()
b.negsel <- list()
b.negsel.ci <- list()
b.negsel.label.list <- list()
SCU.mean <- list()
SCU.median <- list()
for(i.case in c(2, 3)){
  fn.in <- paste(prefix$subset, case.names[i.case], "_PM_scaling.rda", sep = "")
  if(!file.exists(fn.in)){
    stop(paste(fn.in, " is not found.", sep = ""))
  }
  load(fn.in)

  phi.pm[[case.names[i.case]]] <- phi.PM
  phi.median[[case.names[i.case]]] <- phi.MED
  phi.ci[[case.names[i.case]]] <- phi.CI
  phi.pm.log10[[case.names[i.case]]] <- phi.PM.log10
  phi.std.log10[[case.names[i.case]]] <- phi.STD.log10
  phi.ci.log10[[case.names[i.case]]] <- phi.CI.log10

  b.pm[[case.names[i.case]]] <- b.PM
  b.ci[[case.names[i.case]]] <- b.ci.PM

  b.negsel[[case.names[i.case]]] <- b.negsel.PM
  b.negsel.ci[[case.names[i.case]]] <- b.negsel.ci.PM
  b.negsel.label.list[[case.names[i.case]]] <- b.negsel.label

  b <- convert.bVec.to.b(b.PM, aa.names)
  SCU.mean[[case.names[i.case]]] <- calc_scu_values(b, y.list, phi.PM)
  SCU.median[[case.names[i.case]]] <- calc_scu_values(b, y.list, phi.MED)
}

# Get negsel.
all.names <- names(b.pm[[1]])
id.intercept <- grep("(Intercept)", all.names, invert = FALSE)
id.slop <- grep("(Intercept)", all.names, invert = TRUE)


# Set layout.
fn.out <- paste(prefix$plot.multi, case.main, ".pdf", sep = "")
pdf(fn.out, width = 6, height = 10)

# New page.
  new.page(workflow.name, case.main = paste(model, ": ", case.main, sep = ""))

  # Plot Delta.t.
  x <- b.negsel[[2]]
  y <- b.negsel[[1]]
  x.ci <- b.negsel.ci[[2]]
  y.ci <- b.negsel.ci[[1]]
  x.label <- b.negsel.label.list[[1]]
  plot.b.corr(x, y, x.label, x.ci = x.ci, y.ci = y.ci,
              xlab = "With Phi", ylab = "Without Phi",
              main = "Delta.t", add.lm = TRUE)

  # Plot log(mu).
  x <- b.pm[[2]][id.intercept]
  y <- b.pm[[1]][id.intercept]
  x.ci <- b.ci[[2]][id.intercept,]
  y.ci <- b.ci[[1]][id.intercept,]
  x.label <- b.label
  plot.b.corr(x, y, x.label, x.ci = x.ci, y.ci = y.ci,
              xlab = "With Phi", ylab = "Without Phi",
              main = "log(mu)", add.lm = TRUE)

  # Overlap two histograms.
  p.1 <- hist(log10(phi.pm[[2]] / mean(phi.pm[[2]])),
              nclass = 50, plot = FALSE)
  p.2 <- hist(log10(phi.pm[[1]] / mean(phi.pm[[1]])),
              nclass = 50, plot = FALSE)
  xlim <- range(p.1$breaks, p.2$breaks)
  ylim <- range(p.1$counts, p.2$counts)
  plot(p.1, col = "#0000FF50", xlim = xlim, ylim = ylim,
       xlab = "Production Rate (log10)",
       main = "Expression (Posterior Mean)")
  plot(p.2, col = "#FF000050", xlim = xlim, ylim = ylim, add = TRUE)
  legend(xlim[1], ylim[2], c("With Phi", "Without Phi"),
         pch = c(15, 15), col = c("#0000FF50", "#FF000050"), cex = 0.8)

  # Overlap two histograms.
  p.1 <- hist(log10(phi.median[[2]] / mean(phi.median[[2]])),
              nclass = 50, plot = FALSE)
  p.2 <- hist(log10(phi.median[[1]] / mean(phi.median[[1]])),
              nclass = 50, plot = FALSE)
  xlim <- range(p.1$breaks, p.2$breaks)
  ylim <- range(p.1$counts, p.2$counts)
  plot(p.1, col = "#0000FF50", xlim = xlim, ylim = ylim,
       xlab = "Production Rate (log10)",
       main = "Expression (Posterior Median)")
  plot(p.2, col = "#FF000050", xlim = xlim, ylim = ylim, add = TRUE)
  legend(xlim[1], ylim[2], c("With Phi", "Without Phi"),
         pch = c(15, 15), col = c("#0000FF50", "#FF000050"), cex = 0.8)

# New page.
  new.page(workflow.name, case.main = paste(model, ": ", case.main, sep = ""))

  # Plot SCU
  plotprxy(SCU.mean[[2]]$SCU, SCU.mean[[1]]$SCU,
           xlab = "With Phi SCU (log10)",
           ylab = "Without Phi SCU (log10)",
           main = "SCU (Posterior Mean)")

  # Plot mSCU
  plotprxy(SCU.mean[[2]]$mSCU, SCU.mean[[1]]$mSCU,
           log10.x = FALSE, log10.y = FALSE,
           xlab = "With Phi mSCU",
           ylab = "Without Phi mSCU",
           main = "mSCU (Posterior mean)")

  # Plot SCU
  plotprxy(SCU.median[[2]]$SCU, SCU.median[[1]]$SCU,
           xlab = "With Phi SCU (log10)",
           ylab = "Without Phi SCU (log10)",
           main = "SCU (Posterior Mean)")

# New page.
  new.page(workflow.name, case.main = paste(model, ": ", case.main, sep = ""))

  # For x-y plots.
  x <- log10(phi.pm[[2]] / mean(phi.pm[[2]]))
  y <- log10(phi.pm[[1]] / mean(phi.pm[[1]]))
  xlim <- ylim <- range(c(x, y))

  # Plot prxy.
  plotprxy(10^(phi.pm.log10[[2]]), 10^(phi.pm.log10[[1]]),
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior log10 Mean)")

  # Plot prxy with outliers labeled.
  plotprxy(10^(phi.pm.log10[[2]]), 10^(phi.pm.log10[[1]]),
           y.ci = 10^(phi.ci.log10[[1]]),
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior log10 Mean)")

  # Plot prxy.
  plotprxy(phi.median[[2]], phi.median[[1]],
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior Median)")

  # Plot prxy with outliers labeled.
  plotprxy(phi.median[[2]], phi.median[[1]],
           y.ci = phi.ci[[1]],
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior Median)")

  # Plot prxy.
  plotprxy(phi.pm[[2]], phi.pm[[1]],
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior Mean)")

  # Plot prxy with outliers labeled.
  plotprxy(phi.pm[[2]], phi.pm[[1]],
           y.ci = phi.ci[[1]],
           weights = 1 / phi.std.log10[[1]],
           xlim = xlim, ylim = ylim,
           xlab = "With Phi Production Rate (log10)",
           ylab = "Without Phi Production Rate (log10)",
           main = "Expression (Posterior Mean)")

# New page.
  new.page(workflow.name, case.main = paste(model, ": ", case.main, sep = ""))

  # Add qqplot.
  x <- log10(phi.pm[[2]] / mean(phi.pm[[2]]))
  y <- log10(phi.pm[[1]] / mean(phi.pm[[1]]))
  xlim <- ylim <- range(c(x, y))
  qqplot(x, y,
         xlim = xlim, ylim = ylim,
         xlab = "With Phi Production Rate (log10)",
         ylab = "Without Phi Production Rate (log10)",
         main = "Q-Q (Posterior Mean)",
         pch = 20, cex = 0.6)
  abline(a = 0, b = 1, col = 4, lty = 2)

  # Add qqplot for non-log.
  x <- phi.pm[[2]] / mean(phi.pm[[2]])
  y <- phi.pm[[1]] / mean(phi.pm[[1]])
  xlim <- ylim <- range(c(x, y))
  qqplot(x, y,
         xlim = xlim, ylim = ylim,
         xlab = "With Phi Production Rate",
         ylab = "Without Phi Production Rate",
         main = "Q-Q (Posterior Mean)",
         pch = 20, cex = 0.6)
  abline(a = 0, b = 1, col = 4, lty = 2)

  # Add qqplot.
  x <- log10(phi.median[[2]] / mean(phi.median[[2]]))
  y <- log10(phi.median[[1]] / mean(phi.median[[1]]))
  xlim <- ylim <- range(c(x, y))
  qqplot(x, y,
         xlim = xlim, ylim = ylim,
         xlab = "With Phi Production Rate (log10)",
         ylab = "Without Phi Production Rate (log10)",
         main = "Q-Q (Posterior Median)",
         pch = 20, cex = 0.6)
  abline(a = 0, b = 1, col = 4, lty = 2)

  # Add qqplot for non-log.
  x <- phi.median[[2]] / mean(phi.median[[2]])
  y <- phi.median[[1]] / mean(phi.median[[1]])
  xlim <- ylim <- range(c(x, y))
  qqplot(x, y,
         xlim = xlim, ylim = ylim,
         xlab = "With Phi Production Rate",
         ylab = "Without Phi Production Rate",
         main = "Q-Q (Posterior Median)",
         pch = 20, cex = 0.6)
  abline(a = 0, b = 1, col = 4, lty = 2)

dev.off()