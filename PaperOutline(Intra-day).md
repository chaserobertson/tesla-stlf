# **Outlines for "Intra-day Electricity Demand and Temperature"**

## Introduction & Concepts
#### 1. Objective: find relationship between:
* dependent variable: High frequency electricity demand (per 5 min) 
* variables:
  * intra-day temperature variation
  * Time:
    * DST Datlight Saving TIme, not solar time
    * time of the day
    * time of the year

#### 2. Some observations:
* None of existing papers use the above three factors at the same time
* Makes common sense, air conditioners & cooler leads to increased electricity consumption
* <ins>low impact on electricity demand:<ins> Sunshine hours, rainfall, wind, humidity, cloudiness

#### 3. Time weighted temperature model:
* assigns different temperature signal weighting based on the DST time
* temperature variation away from the maximum comfort temperature (20°C) is time sensitive
  * more sensitive to temperature variation away from the ‘comfort’ during periods of high human activity
  * ___time sensitivity:___
    * morning: 4 am - 9 am; 
    * night: decline begins at 18:30pm
  * using ___DST time___ is confirmed
  * sensitivity of electricity demand to temperature is a function of time of day

#### 4. Generalised Additive Model (GAM) MAPE 3.20% :
* Australian Energy Market Operator (AEMO) next day forecast 2.04% - not publicly available
* multivariate prediction variables
* advanced but opaque forecasting techniques Deep Neural Networks or Gradient Boosting
* GAM model is transparent
* Entire dataset model and seasonal model
- - - -
## Data
#### 1. electricity demand: 
* 5 minute frequency
* in Megawatts (MW)
* Region: Australian state of New South Wales (NSW) and the Australian Capital Territory (ACT) 
* __Time range: 3-February-2014 to 2-February-2015 (250 days, and 288 5-minute observations on each day)__
* including households, companies, industrial and public sectors
* Restricted to business days only (NO weekends & public holidays)
  
#### 2. temperature data:
* 5 minute frequency
* 20°C = comfort temperature
* valid for 61% of population of the NSW/ACT electricity demand area
* Improve accuracy by using: multiple temperature (and potentially humidity) measurements from different suburban, urban and rural areas and set up an adequate average temperature index weighted by population
  
#### 3. Some preliminary analysis on sensitivity of the demand with respect to temperature: 
$$\ D= α_t^0 + α_t^1|Temp - 20.0| + α_t^2Year + ε $$
* t ∈ [1, ..., 288] (24 * 60 min / 5 min = 288)
* $\ α_t^0 $: intercept (temperature = 20 and Year = 0)
* $\ α_t^1 $: coefficients for empirical time indexed demand sensitivity to temperature
* $\ α_t^2 $: coefficients for cross sectional change in yearly demand
* fit the above linear model 288 times to each 5-min period during the day:
  * Figure1: demand & temperature fluctuating in summer & winter: temperature demand is time dependent
  * Figure2: show the sensitivity of the demand varies in different level of human activities 
    * e.g.: if the temperature at 4am is 12°C which is 8°C colder than the minimum demand comfort temperature, the increase in demand (the coefficient α1 in MW per degree) will be relatively small because of low human activity at 4am
  * other findings: The yearly decline in demand has been concentrated during the daylight hours (demand replacement with solar power), and in particular, the greatest demand falls have been in the morning and afternoon peak periods.
  * __NOTE: South Australia electricity pricing periods:__ 
    * peak: 6am-10am & 3pm-1am
    * shoulder: 1am-6am
    * off-peak: 10am-3pm
- - - -
## Model
#### 1. Model 1: $\ D_t = β_0 + s(Time_t) + β_1|Temp_t - 20.0| + β_2Year_t + ε_t $
* $\ Time_t$ is a scaled time of the year with values in the interval [0,1)
* $\ Temp_t$ is temperature
* DST converted
* $\ s(Time_t)$: daily periodic cyclic empirical function of  over the sample period 
  * the temperature independent electricity demand
  * a daily periodic cyclic empirical function of  over the sample period
  * Use GAM regression to determine the periodic function s(·)
* $\ |Temp_t - 20.0|$
  * temperature dependent electricity demand
  * How is 20 determined?: 
    * fit Model 1 in Equation (3.1) using different temperatures ranging from 17°C to 23°C
    * Table1: $\ β_1|Temp_t - 20.0|$ has a slightly higher t-statistic and the regression has a slightly higher $\ R^2 $
* __$\ R^2$ for model 1 = 0.811__ 

#### 2. Model 2: $\ D_t = β_0 + s(DST_t) + β_1(w(DST_t) * |Temp_t - 20.0|) + β_2Year_t + ε_t $
* the difference between 20°C and 19°C or 21°C is very small, which implies that temperature dependent demand is a non-linear function of the difference between the minimum demand temperature and the measured temperature, with small differences producing little or no change in temperature dependent demand. relationship between the temperature and demand via a non-linear function
* => incorporate a weighted temperature demand signal
* $\ w(DST_t)$:
  * is a piecewise continuous sinusoidal function of DST that returns values between 0 and 1
  * = 1: represents the ‘full’ temperature signal $\ |Temp_t - 20.0|$
  * = 0: completely attenuates the temperature signal
* __$\ R^2$ for model 2 = 0.862__

#### 3. Model 3: $\ D_t = β_0 + s(DST_t) + h(Temp_t) + β_2Year_t + ε_t $
* nonlinear temperature dependent demand model
* captures the relationship between the temperature and demand via a non-linear function modeled by non-periodic splines
* __$\ R^2$ for model 3 = 0.841__ (model 3 is marginally lower compared to model 2, because model 3 does not use time weight the temperature signal by function w(·))
 
#### 4. Model 4: $\ D_t = β_0 + s(DST_t) + h(Temp_t * w(DST_t)) + β_2Year_t + ε_t $
* similar to model 3
* __$\ R^2$ for model 4 = 0.869__  

#### 5. Model 5 👍: $\ D_t = β_0 + s(DST_t) + h(Temp_t * w(DST_t)) + k(Year_t) + ε_t $
* Periodic function with spline term k
* __$\ R^2$ for model 5 = 0.898__  
  
#### 6. Model 6 👍(12 models for each month):  $\ D_t = β_0 + s(DST_t) + β_1(w(DST_t) * |Temp_t - 20.0|) + ε_t $
* Model 1-5 assume time dependent demand s(DST) is stationary across the year
* may be better captured by the seasonal demand model
* fit the following regressions for each calendar month
* Simple version of Model 2 
  
- - - - 
## Predicting electricity demand:
#### 1. 3 models reagarding temperature: 
* Oracle: just actual temperatures and assume they are always known - unrealistic
* Zero: calculate temperatatures of day and night respectively based on calculations (based on maximum and minimum temperatures) from other literature - unrealistic because assuming no information about next day temperatures is available
* Forecast👍: (can get maximum and minimum temperatures directly from official instead of calculating like "Zero")
  * 16:20 DST (‘the 6 o’clock news forecast’) Australian Bureau of Meteorology
  * Use news forecast of next day maximum and minimum temperatures
  * applies Göttsche et al. (2001)’s physics to interpolate intra-day temperatures for the next day

#### 2. Compare results (also including AEMO's secret model)
* Oracle   - best result amonth the 3 (because it is using most accurate actual temperatures), with smallest std & MAPE
* Forecast - intermediate
* Zero     - worst
* AEMO     - best model, but secret...	
  * uses multiple weighted temperature forecasts
  * 30 min model (this is why AEMO line is more smooth)
  
- - - -   
## Conlusion
#### 1. strong relationship between high frequency electricity demand & intra-day temperature by establishing a link between electricity demand and human activity cycle (modelled through the time of the day)
#### 2. using Daylight Saving Time (DST) as an independent variable for the time indexed daily periodic demand consumption function provides a small but highly significant improvement of fit compared to using standard (astronomical) time
#### 3. How to improve:
* include demand weighted temperatures from locations where there are temperature variations of 10°C or more between coastal and inland suburbs of Sydney, which are very common
* include other environmental variables such as: wind, humidity
* try other forecasting techniques such as Deep Neural Networks or Gradient Boosting could be utilised
 
  
  
  
  
  
  
