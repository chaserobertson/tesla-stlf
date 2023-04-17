### GAM & R
#### 1. Intro
* a middle ground between simple models(e.g.: linear) and more complex models black-box ml (e.g.: neural networks)
* can be fit to complex, nonlinear relationships and make good predictions, but we are still able to do inferential statistics and understand and explain the underlying structure.
* ___R⭐___: when fit GAM, we ___wrap the independent variable x in the s()___ -  a smooth function to specify that we want this relationship to be flexible.
  * ___Note❗: need to import "nlme" before "mgcv"!!!!!!!!!!!!___
``` {r}
library(nlme)
library(mgcv)
gam_mod <- gam(y ~ s(x), data = my_data)
```

#### 2. Basis functions
* The flexible smooths in GAMs are actually constructed of many smaller functions - Basis Functions.
* ___Each smooth = sum(basis functions)___
* each basis function is multiplied by a coefficient, each of which is a parameter in the model
* ___R⭐:  coef() - extract the coefficients___
``` {r}
gam_mod <- gam(y ~ s(x), data = my_data)
coef(gam_mod)
```

#### 3. Balancing Wiggliness
* GAM's flexibility makes it easy to over-fit
* ___likelihood:___ measures how well the GAM captures patterns in the data
* ___wiggliness (λ):___ measures complexity, or how much the curve changes shape
* trade-off between likelihood & wiggliness:
$$\ Fit = Likelihood - λ * Wiggliness$$
* This smoothing parameter λ is optimised when R fits a GAM to data

#### 4. Choosing the right smoothing parameter (λ)
* normally we let the package do the work of selecting a smoothing parameter
* ⭐can set manually by: ___"sp = " argument___
``` {r}
gam(y ~ s(x), data = dat, sp = 0.1)
## OR
gam(y ~ s(x, sp = 0.1), data = dat)
```
* ⭐extract sp:
```{r}
model <- gam(y ~ s(x), data = dat, method = "REML")
model$sp
```

* mgcv offers several different methods for selecting smoothing parameters, ___⭐REML(Restricted Maximum Likelihood) method is strongly recommended by most GAM experts___
``` {r}
gam(y ~ s(x), data = dat, method = "REML")
```

#### 5. Number of basis functions (k)- the other factor that affects how wiggly a GAM function can be
* small number of bf - limited wiggliness
* big number of bf - capable of capturing finer patterns
* We just don't want to set k very high, which can result in a model with more parameters than data, or one that is slow to fit
``` {r}
## manually setting
gam(y ~ s(x, k = 3), data = dat, method = "REML")
gam(y ~ s(x, k = 10), data = dat, method = "REML")

## use the defaults:
gam(y ~ s(x), data = dat, method = "REML")
```

#### 6. Multivariate GAMs
* Not every term in a GAM has to be nonlinear
* We can combine linear and nonlinear terms
* linear term:
   * don't wrap the predictor in the s() function___
   * ___nonlinear terms with very high smoothing parameter = linear terms___
``` {r}
gam(hw.mpg ~ s(weight) + length, data = mpg, method = "REML")

## set the smoothing parameter of the length term very high = linear
gam(hw.mpg ~ s(weight) + s(length, sp = 1000), data = mpg, method = "REML")
```

* __⭐categorical terms:__
   * it's important that the variables are ___stored as factors___, because mgcv does not use character variables
   * the ___"by" argument___ to the s() function - tell R to calculate a different smooth for each unique category
   * ___smooth-factor interactions:___ include a varying intercept, in case the different categories are different in overall means in addition to shape of their smooths.
``` {r}
## different smooths for diesel and gas cars, but the diesel smooth is much more uncertain
model 3 = gam(hw.mpg ~ s(weight) + fuel, data = mpg, method = "REML")

## this varying intercept improves the estimate of the smooth for diesel cars
model 3 = gam(hw.mpg ~ s(weight, by = fuel), data = mpg, method = "REML")
