# Distance Moved

MoveApps

Github repository: https://github.com/movestore/DistanceMoved

## Description
Calculation of the cumulative or net distance moved per chosen time interval or for the entire tracking period. 

## Documentation
This app calculates the distance moved per chosen time interval or for the entire tracking period. The distance can be calculated in two ways:

***Cumulative distance***: it calculates the sum of the length of all segments per chosen time interval or the entire track.

***Net displacement***: it calculates the distance of the straight line between the 1st and the last point per chosen time interval or the entire track.

In the 'logs' a message will be displayed informing about the time zone of the data.


### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
Cumulative distance per time interval:

- `plot_DistanceMoved_cumulativeDist_per_TIME-INTERVAL.pdf`: one plot per individual representing the cumulative distance moved within the time interval

- `DistanceMoved_cumulativeDist_per_TIME-INTERVAL.csv`: table containing the cumulative distance values per time interval, per individual

Cumulative distance for entire track:

- `plot_DistanceMoved_cumulativeDist_in_total.pdf`: one plot with the cumulative distance moved in the entire track per individual

- `DistanceMoved_cumulativeDist_per_in_total.csv`: table with the cumulative distance of the entire track per individual

Net displacement per time interval:
 
- `plot_DistanceMoved_netDisplacement_per_TIME-INTERVAL.pdf`: one plot per individual representing the net displacement within the time interval

- `DistanceMoved_netDisplacement_per_TIME-INTERVAL.csv`: table containing the net displacement values per time interval, per individual

Net displacement for entire track:

- `plot_DistanceMoved_netDisplacement_in_total.pdf`: one plot with the net displacement in the entire track per individual

- `DistanceMoved_netDisplacement_in_total.csv`: table with the net displacement of entire track per individual
 

### Parameters
`Distance to be calculated`: one option has to be chosen: `Cumulative distance` or `Net displacement`

`Time unit`: the unit of the time interval for which the distance will be calculated. Available are: `Seconds`, `Minutes`, `Hours`, `Days`, `Month`, `Years`. To select the entire tracking period, `ALL` has to be chosen. Default is `Days`.

`Time length`: a number representing the length of the time unit above. The time interval can be for example '5 Minutes', '12 Hours', '3 Month', '1 Years', etc. If `ALL` is selected in the 'Time unit' above, this number will be ignored. Default is `1`.

`Select units of distance calculation`: units for the distance calculations. Available are: `Centimeters`, `Meters`, `Kilometers`, `Inches`, `Feet`, `Yards` & `Miles`. Default units are taken from the map units of the data. 

### Null or error handling
**Data**: The full input dataset is returned for further use in a next App and cannot be empty.
