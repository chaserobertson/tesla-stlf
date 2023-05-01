##
## Shift or lag a vector.
##

shift<-function(x,shift_by){
    stopifnot(is.numeric(shift_by))
    stopifnot(is.numeric(x))
 
    if (length(shift_by)>1)
        return(sapply(shift_by,shift, x=x))
 
    out<-NULL
    abs_shift_by=abs(shift_by)
    if (shift_by > 0 )
        out<-c(tail(x,-abs_shift_by),rep(NA,abs_shift_by))
    else if (shift_by < 0 )
        out<-c(rep(NA,abs_shift_by), head(x,-abs_shift_by))
    else
        out<-x
    out
}

lag <- function(x,lag) { shift(x,-lag) }

##
## The piecewise human activity function to weight the temp signal 
## Time must be in the interval [0,1]
## The morningmintime is a constant specifying the time of minimum activity; generally 4am- (4/24).
## The morningmaxtime is a constant specifying the morning maximum activity; generally 8-9am 
## Specified as (8/24) or (9/24).
## Morning max time is when the morning maximum peak value is reached.
## plateaubegintime is when the mid-day plateau begins.
## the mid-day plateau will between 0.8 <= plateau <= 1.
## plateauendtime is when the mid-day plateau ends and the climb to the afternoon peak begins
## The afternoonmaxtime is a constant specifying the time of the afternoon activity decline; generally 18:00.
## Specified as (18/24) 
## tempsensitivity(0) = midnightvalue, tempsensitivity(1) = midnightvalue

tempsensitivity <- function( temptime
                           , amplitude
                           , morningmintime
                           , morningmin
                           , morningmaxtime
                           , morningmax
                           , plateaubegintime
                           , middayplateau
                           , plateauendtime
                           , afternoonmaxtime
                           , afternoonmax
                           , midnightvalue) {

    if (temptime < 0) {
    
        sensitivity <- midnightvalue

    } else if (temptime >= 0 & temptime < morningmintime) {
    
        sensitivity <- sin(pi + (0.5 * pi * (temptime / morningmintime)))
        sensitivity <- sensitivity * (midnightvalue - morningmin)
        sensitivity <- midnightvalue + sensitivity

    } else if (temptime >= morningmintime & temptime < morningmaxtime) {
    
        sensitivity <- sin((1.5 * pi) + (pi * ((temptime - morningmintime) / (morningmaxtime-morningmintime))))
        sensitivity <- 0.5 * (sensitivity + 1) * (morningmax - morningmin)
        sensitivity <- morningmin + sensitivity       

    } else if (temptime >= morningmaxtime & temptime < plateaubegintime) {
    
        sensitivity <- sin((1.5 * pi) + (pi * ((plateaubegintime-temptime) / (plateaubegintime-morningmaxtime))))
        sensitivity <- 0.5 * (sensitivity + 1) * (morningmax - middayplateau)
        sensitivity <- middayplateau + sensitivity

    } else if (temptime >= (morningmaxtime) & temptime < plateauendtime) {
    
        sensitivity <- middayplateau
    
    } else if (temptime >= plateauendtime & temptime < afternoonmaxtime) {
    
        sensitivity <- sin((1.5 * pi) + (pi * ((temptime-plateauendtime) / (afternoonmaxtime-plateauendtime))))
        sensitivity <- 0.5 * (sensitivity + 1) * (afternoonmax - middayplateau)
        sensitivity <- middayplateau + sensitivity

    } else if (temptime >= afternoonmaxtime & temptime < 1) {
    
    
        sensitivity <- sin((pi/2) + ((pi/2) * ((temptime-afternoonmaxtime) / (1 - afternoonmaxtime))))
        sensitivity <- sensitivity * (afternoonmax - midnightvalue)
        sensitivity <- midnightvalue + sensitivity    
    
    } else if (temptime >= 1) {
    
        sensitivity <- midnightvalue
    
    }    

    sensitivity <- amplitude * sensitivity   

    return(sensitivity)    

}

#
# Wrapper function accepts a vector of values between [0,1]
# and returns a vector of values between [0,1]
#

amplitude_const = 1.0 ## Scales the function
morningmintime_const = (4/24) ## 4am morning minimum time 
morningmin_const = 0.2 ## morning maximum value
morningmaxtime_const = (9/24) ## 8am morning maximum is reached
morningmax_const = 0.7 ## morning maximum value
plateaubegintime_const = (11/24) ## 11am mid-day plateau begins
middayplateau_const = 0.6 ## mid-day plateau value
plateauendtime_const = (16.5/24) ## 4pm mid-day plateau ends
afternoonmaxtime_const = (18.5/24) ## 7pm night decline begins
afternoonmax_const = 1.0 ## 7pm night maximum
midnightvalue_const = 0.35  ## The value at midnight

tempsensvector <- function(timevector
                        , amplitude=amplitude_const
                        , morningmintime=morningmintime_const
                        , morningmin=morningmin_const
                        , morningmaxtime=morningmaxtime_const
                        , morningmax=morningmax_const
                        , plateaubegintime=plateaubegintime_const
                        , middayplateau=middayplateau_const
                        , plateauendtime=plateauendtime_const
                        , afternoonmaxtime=afternoonmaxtime_const
                        , afternoonmax=afternoonmax_const
                        , midnightvalue=midnightvalue_const) {

##    str(timevector)

    sensvector <- vector(mode="numeric", length=0)

    for (temptime in timevector) {

        sensitivity <- tempsensitivity( temptime
                                      , amplitude      
                                      , morningmintime
                                      , morningmin                                      
                                      , morningmaxtime
                                      , morningmax
                                      , plateaubegintime 
                                      , middayplateau 
                                      , plateauendtime 
                                      , afternoonmaxtime
                                      , afternoonmax
                                      , midnightvalue)
        sensvector <- c(sensvector, sensitivity)
    
    }

    return(sensvector)

}


#
# Wrapper function accepts a vector of temperatures
# and returns a vector of temperature signals
#

comforttemp_const = 20  ## minimum electricity demand temperature.
coldtemp_const = 1.0  ## scale the cold temp signal
hottemp_const = 1.0  ## scale the warm temp signal.


tempsignal <- function(tempvector, comforttemp=comforttemp_const) {

##    str(timevector)

    signalvector <- vector(mode="numeric", length=0)

    for (temp in tempvector) {

        signal <- temp - comforttemp
        
        if (signal < 0) {
        
            signal <- -1.0 * coldtemp_const * signal
        
        } else {
        
            signal <- hottemp_const * signal
        
        
        }
        
        signalvector <- c(signalvector, signal)
    
    }

    return(signalvector)

}



#
# Wrapper function accepts a vector of Times
# and returns a vector of weights dependent on time.
#
timeweight_const = 1.0  ## scale the weighted temp signal.

wtdtimesignal <- function(timevector, timeweight = timeweight_const) {

    wtdtimevector <- vector(mode="numeric", length=0)
    
    wtdtimevector <- (timeweight * tempsensvector(timevector)) 

    wtdtimevector <- wtdtimevector + (1.0 - timeweight)

    return(wtdtimevector)

}

#
# Wrapper function accepts a vector of temperatures and Times
# and returns a vector of time weighted temperature signals
#
timeweight_const = 1.0  ## scale the warm temp signal.

wtdtempsignal <- function(timevector, tempvector, timeweight = timeweight_const) {

    wtdtempvector <- vector(mode="numeric", length=0)
    
    wtdtempvector <- tempsignal(tempvector) * wtdtimesignal(timevector, timeweight)

    return(wtdtempvector)

}

#
# Wrapper function accepts a vector of temperatures and Times
# and returns a vector of time weighted temperatures
# Note this does NOT convert the temperature into a signal (abs(Temp-20))
# It simply weights the temperature difference from 20. 
#
coldtemp_const = 1.0  ## scale the cold temp signal
hottemp_const = 1.0  ## scale the warm temp signal.
mintemp_const = 20    ## 

wtdtemp <- function(timevector, tempvector, tempcomfort = mintemp_const) {

    wtdtempvector <- vector(mode="numeric", length=length(tempvector))
	
	wtdtempvector <- tempvector - tempcomfort   # subtract the comfort temperature

    sensvector <- vector(mode="numeric", length=length(timevector))
	
	for (index in 1:length(timevector)) {

        sensitivity <- tempsensitivity(timevector[index]
                                      , amplitude_const        
                                      , morningmintime_const 
                                      , morningmin_const 
                                      , morningmaxtime_const
                                      , morningmax_const
                                      , plateaubegintime_const 
                                      , middayplateau_const
                                      , plateauendtime_const 
                                      , afternoonmaxtime_const
                                      , afternoonmax_const
                                      , midnightvalue_const)

		signal <- wtdtempvector[index]
									   
		if (signal < 0) {
        
			wtdsignal <- (coldtemp_const * signal * sensitivity) + ((1-coldtemp_const) * signal) 
        
		} else {
        
			wtdsignal <- (hottemp_const * signal * sensitivity) + ((1-hottemp_const) * signal)
                
		}

		sensvector[index] = wtdsignal
		
    }

#	print("senvector dim=")
#	print(length(sensvector))
#	print(typeof(sensvector))
#	print(sensvector[1:100])
	
	wtdtempvector <- sensvector
	wtdtempvector <- wtdtempvector + tempcomfort   # add back the comfort temperature
	
    return(wtdtempvector)

}



#
# Load the forecasting data structures.
#

const_linearmargin = 3   # more than 3 degrees is linear
const_quadcoefficient = (1/(2 * const_linearmargin)) # quadratic coefficent
const_piecewise_adjust = (-1.0 * const_linearmargin/2)
 
roundedbottom <- function(tempvector, tempcomfort = mintemp_const) {

  signalvector <- vector(mode="numeric", length=length(tempvector))
  
	for (index in 1:length(tempvector)) {

    rawsignal = abs(tempvector[index] - tempcomfort)
  
    if (rawsignal > const_linearmargin) {
 
      signal = rawsignal + const_piecewise_adjust

    } else {
  
      signal = rawsignal * rawsignal * const_quadcoefficient
  
    }

    signalvector[index] = signal
    
  }  

  return(signalvector)
  
}

#
# Wrapper function accepts a vector of temperatures and Times
# and returns a vector of time weighted temperature signals
#

wtdroundsignal <- function(timevector, tempvector, timeweight = timeweight_const) {

    wtdtempvector <- vector(mode="numeric", length=0)
    
    wtdtempvector <- roundedbottom(tempvector) * wtdtimesignal(timevector, timeweight)

    return(wtdtempvector)

}

#
# Load the forecasting data structures.
#

initializeforecast <- function() {


  


}

