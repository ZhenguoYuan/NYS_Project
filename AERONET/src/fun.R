angstrom <- function(band, band.ref, AOT.ref, band.1, AOT.1, band.2, AOT.2){
  AOT <- AOT.ref * ((band / band.ref) ^ (log(AOT.1 / AOT.2) / log(band.1 / band.2)))
  return(AOT)
}