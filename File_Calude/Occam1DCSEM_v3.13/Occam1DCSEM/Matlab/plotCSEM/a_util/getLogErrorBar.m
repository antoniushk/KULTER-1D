function [yd ystdU ystdL ] = getLogErrorBar(ex,exsd)
     
    yd = log10(abs(ex)); 
    ystdU = ( log10( abs(ex)  + exsd )  - log10( abs(ex) ) );
    ystdL = ( log10( abs(ex) ) - log10( abs(ex)  - exsd) ) ;