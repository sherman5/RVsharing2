context('RVsharing top level')

test_that('args processed correctly',
{
    data(samplePedigrees)
    ped <- samplePedigrees[[1]]
    f <- function(n) rep(1,n)

    expect_error(RVsharing(ped, alleleFreq=0.1, kinshipCoeff=0.1))
    expect_warning(RVsharing(ped, alleleFreq=0.1, founderDist=f))
    expect_warning(RVsharing(ped, kinshipCoeff=0.1, founderDist=f))
})

test_that('list of pedigrees',
{
    data(samplePedigrees)

    probs <- sapply(samplePedigrees, RVsharing)
    ids <- as.character(sapply(samplePedigrees, function(p) p$famid[1]))
    result <- RVsharing(samplePedigrees)

    expect_equal(names(result), ids)
    expect_equal(unname(result), unname(probs))
})

test_that('RVsharing runs on all sample pedigrees',
{
    data(samplePedigrees)
    
    expect_equal(length(samplePedigrees), 9)
    expect_equal(RVsharing(samplePedigrees[[1]]), 0.0667, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[2]]), 0.0159, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[3]]), 0.0039, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[4]]), 0.0118, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[5]]), 0.0013, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[6]]), 0.0492, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[7]]), 0.1130, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[8]]), 0.0187, tolerance=1e-3)
    expect_equal(RVsharing(samplePedigrees[[9]]), 0.0028, tolerance=1e-3)
})

test_that('splitPed returns consistent results',
{
    data(samplePedigrees)
    
    expect_equal(length(samplePedigrees), 9)
    res8 <- RVsharing(samplePedigrees[[8]], splitPed=TRUE)
    expect_true(all.equal(res8, c(0.0187, 0.4997, 0.4815), tol=1e-3))
})

test_that('monte carlo close to exact',
{
    set.seed(42)
    monteCarloComp <- function(ped, freq=NA, kin=NA)
    {
        abs(RVsharing(ped, alleleFreq=freq, kinshipCoeff=kin) - 
            RVsharing(ped, alleleFreq=freq, kinshipCoeff=kin, nSim=5e4))
    }

    data(samplePedigrees)
    tol <- 0.01
    MAF <- 0.01
    kCoeff <- 0.01

    expect_equal(monteCarloComp(samplePedigrees$firstCousinPair),
        0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinPair),
        0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinPairWithLoop),
        0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$firstCousinInbreeding),
        0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$twoGenerationsInbreeding),
        0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$firstCousinPair,
        freq=MAF), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinTriple,
        freq=MAF), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinPairWithLoop,
        freq=MAF), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$firstCousinInbreeding,
        freq=MAF), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$twoGenerationsInbreeding,
        freq=MAF), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$firstCousinPair,
        kin=kCoeff), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinTriple,
        kin=kCoeff), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$secondCousinPairWithLoop,
        kin=kCoeff), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$firstCousinInbreeding,
        kin=kCoeff), 0, tolerance=tol)
    expect_equal(monteCarloComp(samplePedigrees$twoGenerationsInbreeding,
        kin=kCoeff), 0, tolerance=tol)
})
