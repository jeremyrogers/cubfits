rm(list = ls())

library(cubfits, quiet = TRUE)
set.seed(1234)

# Generate sequences.
da.roc <- simu.orf(length(ex.train$phi.Obs), bInit$roc,
                   phi.Obs = ex.train$phi.Obs, model = "roc")
names(da.roc) <- names(ex.train$phi.Obs)
write.seq(da.roc, "toy_roc.fasta")

# Read seqeuences back.
seq.roc <- read.seq("toy_roc.fasta")
seqstring.roc <- convert.seq.data.to.string(seq.roc)
phi.Obs <- ex.train$phi.Obs / mean(ex.train$phi.Obs)
phi <- data.frame(ORF = names(phi.Obs), phi.value = phi.Obs)

# Generate data structures from sequences.
aa.list <- names(bInit$roc)
reu13.df <- gen.reu13.df(seqstring.roc, phi, aa.list = aa.list)
n <- gen.n(seqstring.roc, aa.list = aa.list)
y <- gen.y(seqstring.roc, aa.list = aa.list)

# Run codon fits.
.CF.AC$renew.iter <- 3
ret.time <- system.time({
  ret <- cubfits(reu13.df, phi.Obs, y, n,
                 nIter = 10, burnin = 10,
                 phi.DrawScale = 0.01,
                 verbose = TRUE, report = 5,
                 model = "roc", adaptive = "simple")
})

x <- rowMeans(do.call("cbind", ret$phi.Mat)[, 11:20])
y <- ex.train$phi.Obs
plotprxy(x, y)

x <- log10(x / mean(x))
y <- log10(y / mean(y))
print(mean(x))
print(summary(lm(y ~ x))$r.squared)
