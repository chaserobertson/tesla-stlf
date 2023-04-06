# Short-Term Load Forecasting for TESLA Asia Pacific

## Project background
As the world and New Zealand begin to invest and implement more renewable energy such as wind
farms and rooftop solar panels, there are additional challenges to forecast the generation and load
demand. Innovation will be required to model the uptake in EV use, increased efficiency of solar
panels and wind turbines, dynamic panels which adjust to the direction of the sun.
The uptake in solar PV has been much higher in Australia than in New Zealand. In Australia, cloud
cover has a massive impact on the amount of electricity solar panels will generate. One minute the
sky will be clear and blue so the electricity load will be low (since everyone is using their own solar
energy). Clouds may come over the next minute and electricity load will skyrocket as everyone will
need to use electricity from the grid. Modelling this embedded solar generation and forecasting the
uptake in New Zealand will help reduce volatility in the electricity system, particularly as airports and
farms in New Zealand have begun adopting large scale solar farms.


## Project objectives
- Scrape and collate relevant data for data cleaning and model building purposes
- Perform feature selection and understand relationships between weather variables and solar and/or wind generation
- Develop statistical/machine learning models to forecast solar generation and/or wind generation
- Gain an understanding of TESLA and the energy sector in the Asia Pacific
- Write up findings into a dissertation
- Present key findings to the TESLA team

## Data Sources
Data is currently stored in the `data` directory, but can also be pulled from the original source, [Australia Energy Market Operator](https://aemo.com.au/energy-systems/electricity/national-electricity-market-nem/data-nem).

Various aggregations and merges have been conducted on the source data and saved - this may call for some way of distinguising between source and modified data files. Todo.

## Actions
Next steps are to replicate the model specified in McCulloch and Ignatieva's "Intra-day Electricity Demand and Temperature".

## Literature Cited
- McCulloch and Ignatieva: "Intra-day Electricity Demand and Temperature"

Perhaps useful for building on the base model in the future:
- Nassif et al: "Artificial Intelligence and Statistical Techniques in Short-Term Load Forecasting: A Review"
