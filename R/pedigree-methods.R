# make the S3 class for pedigrees formal
setOldClass('pedigree')

#################### GENERICS ####################

#' ratio of excess kinship among descendants over mean kinship among
#' founders
#' @export
#' @docType methods
#' @rdname ComputeKinshipPropCoef-methods
#' 
#' @description Computes, for each pair of final descendants in the
#' pedigree structure contained in the pedigree object, the ratio of
#' the difference between the inferred and expected kinship coefficient
#' for the pair over the mean kinship among founders.
#' @details The ratio for each pair of final descendants is computed
#' using equation (A1) of Bureau et al. Dividing the difference between
#' the inferred and expected kinship coefficient for each pair by this ratio
#' gives a pair-specific estimate of the mean kinship among founders, which
#' can then be averaged over all pairs of final descendants from the same
#' population to obtain a global estimate of the mean kinship among founders.
#' @param ped pedigree object (S3)
#' @return a symmetric matrix of ratios for all pair of final descendants
#' in the pedigree structure contained in the pedigree
#' @examples
#' data(samplePedigrees)
#' ComputeKinshipPropCoef(samplePedigrees$firstCousinTriple)
#' @references Bureau, A., Younkin, S., Parker, M.M., Bailey-Wilson, J.E.,
#' Marazita, M.L., Murray, J.C., Mangold, E., Albacha-Hejazi, H., Beaty, T.H.
#' and Ruczinski, I. (2014) Inferring rare disease risk variants based on
#' exact probabilities of sharing by multiple affected relatives.
#' Bioinformatics, 30(15): 2189-96, doi:10.1093/bioinformatics/btu198.
setGeneric('ComputeKinshipPropCoef', function(ped)
    {standardGeneric('ComputeKinshipPropCoef')})

#' extract useful information from a pedigree
#' @export
#' @docType methods
#' @rdname processPedigree-methods
#' 
#' @description Extract key information from a pedigree object, which makes
#' subsequent computations much easier.
#' @param ped pedigree object (S3)
#' @param carriers subjects in which the rare variant is seen
#' @return list containing relevant pedigree info
#' @examples 
#' data(samplePedigrees)
#' processPedigree(samplePedigrees$firstCousinPair)
setGeneric('processPedigree', function(ped, carriers=NULL)
    {standardGeneric('processPedigree')})

#################### METHODS ####################

#' @rdname processPedigree-methods
#' @aliases processPedigree
setMethod('processPedigree', signature(ped='pedigree'),
function(ped, carriers)
{
    # relabel subjects and get basic ped info
    origID <- ped$id
    ped$id <- 1:length(ped$id)
    parents <- sapply(ped$id, function(i) c(ped$findex[i], ped$mindex[i]))
    founders <- which(parents[1,] == 0)
    finalDescendants <- which(!(ped$id %in% c(parents[1,], parents[2,])))
    if (!is.null(carriers)) carriers <- which(origID %in% carriers)
    
    # get affected, default to finalDescendants if not provided and no carriers specified
    # or the union of finalDescendants and carriers if carriers are specified
    if (length(ped$affected)) affected <- which(ped$affected == 1)
    else
    {
    	if (is.null(carriers)) affected <- finalDescendants
    	else affected <- union(carriers,finalDescendants)
    }
    # carriers default to affected if not provided
    if (is.null(carriers))   carriers <- affected

    # check pedigree is valid
    #if (sum(affected %in% founders) > 0)
    #    stop('some founders are affected')
    #if (length(affected) < 2)
    #    stop('need at least 2 affected subjects')
    if (sum(!carriers %in% affected) > 0)
        stop('carriers must be a subset of affected')

    # save info in list
    return(list('origID'=origID, 'ped'=ped, 'parents'=parents,
        'founders'=founders, 'affected'=affected, 'size'=length(ped$id),
        'carriers'=carriers, 'id'=ped$id, 'finalDescendants'=finalDescendants))
})

#' @rdname ComputeKinshipPropCoef-methods
#' @aliases ComputeKinshipPropCeof
setMethod('ComputeKinshipPropCoef', signature(ped='pedigree'),
function(ped)
{
    procPed <- processPedigree(ped)

    # inner term in summation, equation (5) of supplement to Bureau et al.
    term <- function(i1, i2, f1, f2)
    {
        d <- ancestorDistance(procPed,f1,i1) + ancestorDistance(procPed,f2,i2)
        0.5^d
#        ifelse(areMating(procPed, f1, f2), 0.5^(d-1), 0.5^d)
    }

    # sum inner term over all pairs of common ancestors among the founders
    sumTerm <- function(i1, i2)
    {
        founders1 <- procPed$founders[sapply(procPed$founders, isDescendant, procPed=procPed, d=i1)]
        founders2 <- procPed$founders[sapply(procPed$founders, isDescendant, procPed=procPed, d=i2)]

        total <- 0
        for (f1 in founders1)
        {
            for (f2 in founders2)
            {
                if (f1 != f2)
                    total <- total + term(i1, i2, f1, f2)
            }
        }
        return(total)
    }

    # create matrix of coefficients
    N <- length(procPed$finalDescendants)
    mat <- matrix(0, N, N)
    genFunc <- function(i,j) ifelse(i==j, NA,
        sumTerm(procPed$finalDescendants[i], procPed$finalDescendants[j]))
    mat <- matrix(mapply(genFunc, row(mat), col(mat)), nrow = nrow(mat))
    rownames(mat) <- colnames(mat) <- procPed$finalDescendants
    return(mat)
})

#################### HELPER FUNCTIONS ####################

#' determine if one subject is a descendant of another
#' @keywords internal
#'
#' @param procPed pedigree that has been through \code{processPedigree}
#' @param a ancestor subject
#' @param d descendant subject
#' @return true if d is descended from a
isDescendant <- function(procPed, a, d)
{
    if (d == 0) FALSE
    else if (any(a %in% procPed$parents[,d])) TRUE
    else any(sapply(procPed$parents[,d], isDescendant, procPed=procPed, a=a))
}

#' distance between a descendant and an ancestor
#' @keywords internal
#'
#' @param procPed pedigree that has been through \code{processPedigree}
#' @param a ancestor subject
#' @param d descendant subject
#' @return minimum distance (number generations) between a and d
ancestorDistance <- function(procPed, a, d)
{
    p1 <- procPed$parents[1,d]
    p2 <- procPed$parents[2,d]

    if (any(a %in% procPed$parents[,d]))
        1
    else if (isDescendant(procPed, a, p1) & isDescendant(procPed, a, p2))
        1 + min(ancestorDistance(procPed,a,p1), ancestorDistance(procPed,a,p2))
    else if (isDescendant(procPed, a, p1))
        1 + ancestorDistance(procPed, a, p1)
    else if (isDescendant(procPed, a, p2))
        1 + ancestorDistance(procPed, a, p2)
    else
        stop(paste('ancestorDistance called on non-descendant', a, d))
}

#' determine if two subjects have a child together
#' @keywords internal
#'
#' @param procPed pedigree that has been through \code{processPedigree}
#' @param f1 subject 1
#' @param f2 subject 2
#' @return true if both subjects share a child
areMating <- function(procPed, f1, f2)
{
    sum(apply(procPed$parents, 2, function(p) f1 %in% p & f2 %in% p)) > 0
}

#' determine if subjects are descended from founders
#' @keywords internal
#'
#' @param procPed pedigree that has been through \code{processPedigree}
#' @param subjects vector of subject ids
#' @param founders vector of founder ids
#' @return data frame with 0/1 for if a subject if descended from founder
founderOccurence <- function(procPed, subjects, founders)
{
    df <- as.data.frame(sapply(subjects, function(sub)
        sapply(founders, function(found) 
            as.numeric(isDescendant(procPed, found, sub))
        )
    ))
    colnames(df) <- subjects
    rownames(df) <- founders
    return(df)
}

#' deprecated function
#' @export
#' @description This function is deprecated with version >= 2.0
#' and should not be used.
#' @param ... arguments to the old function
#' @return none
#' @examples tryCatch(ped2trio(), error = function(e) message(e))
ped2trio <- function(...)
{
    stop(paste('function deprecated with version >= 2.0, no',
        'longer neccesary to process pedigrees into trios'))
}
