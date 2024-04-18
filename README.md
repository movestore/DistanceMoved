# Distance Moved

MoveApps

Github repository: <https://github.com/movestore/DistanceMoved>

## Description

Calculate the cumulative distance moved, net displacement, or maximum net displacement across the data at a chosen time interval (for example, daily net displacements) or for the entire period of each track.

## Documentation

This app calculates the distance moved by each track per a chosen time interval or for the entire tracking period. The distance can be calculated one of in three ways:

***Cumulative distance*** calculates the sum of the length of all segments (straight-line distance between consecutive location records in a track) per chosen time interval or the entire track.

***Net displacement*** calculates the distance of the straight line between the first and the last point per chosen time interval or the entire track.

***Maximum net displacement*** calculates the maximum straight-line distance of the distance matrix between all pairs of locations per chosen time interval or the entire track.

The intervals will be defined by rounding timestamps to the chosen interval and determining track segments (consecutive location records) from the data set that fall within each interval. The break point between intervals is defined at the start of the interval: "00" for seconds, minutes or hours; midnight ("00:00:00") UTC on the day; and midnight on the first day of the month or year. The 'logs' will include a message noting the time zone of the data.

### Input data

move2_locs

### Output data

move2_locs

### Artefacts

Two output files are provided, with the content depending on the settings chosen. All .csv tables include include the rounded timestamps defining the interval break points and the first and last timestamp within the data that fall within the chosen interval.

*Cumulative distance per time interval*:

-   `plot_DistanceMoved_cumulativeDist_per_TIME-INTERVAL.pdf`: one plot per track, representing the cumulative distance moved for each time interval across the tracking period

-   `DistanceMoved_cumulativeDist_per_TIME-INTERVAL.csv`: table containing the cumulative distance values per time interval, per track

*Cumulative distance for entire track*:

-   `plot_DistanceMoved_cumulativeDist_in_total.pdf`: one plot with the cumulative distance moved in the entire track per track

-   `DistanceMoved_cumulativeDist_per_in_total.csv`: table with the cumulative distance of the entire track per track

*Net displacement per time interval*:

-   `plot_DistanceMoved_netDisplacement_per_TIME-INTERVAL.pdf`: one plot per track representing the net displacement within the time interval

-   `DistanceMoved_netDisplacement_per_TIME-INTERVAL.csv`: table containing the net displacement values per time interval, per track

*Net displacement for entire track*:

-   `plot_DistanceMoved_netDisplacement_in_total.pdf`: one plot with the net displacement in the entire track per individual

-   `DistanceMoved_netDisplacement_in_total.csv`: table with the net displacement of entire track per individual

*Maximum net displacement per time interval*:

-   `plot_DistanceMoved_maxNetDisplacement_per_TIME-INTERVAL.pdf`: one plot per individual representing the maximum net displacement within the time interval

-   `DistanceMoved_maxNetDisplacement_per_TIME-INTERVAL.csv`: table containing the maximum net displacement values per time interval, per individual

*Maximum net displacement for entire track*:

-   `plot_DistanceMoved_maxNetDisplacement_in_total.pdf`: one plot with the maximum net displacement in the entire track per individual

-   `DistanceMoved_maxNetDisplacement_in_total.csv`: table with the maximum net displacement of entire track per individual

### Settings

**Distance to be calculated (`distMeasure`):** one option has to be chosen: `Cumulative distance`, `Net displacement` or `Maximum net displacement`. *Cumulative distance* calculates the sum of the length of all segments per chosen time interval or the entire track. *Net displacement* calculates the distance of the straight line between the first and the last point per chosen time interval or the entire track. *Maximum net displacement* returns the maximum straight line distance of the distance matrix between all pairs of locations per chosen time interval or the entire track.

**Time unit (`time_unit`):** the unit of the time interval for which the distance will be calculated. Available are: `Seconds`, `Minutes`, `Hours`, `Days`, `Month`, `Years`. To select the entire tracking period, `ALL` has to be chosen. Default is `Days`.

**Time length (`time_numb`):** a number representing the length of the time unit above. The time interval can be for example '5 Minutes', '12 Hours', '3 Month', '1 Years', etc. If `ALL` is selected in the 'Time unit' above, this number will be ignored. Default is `1`.

**Distance unit (`dist_unit`):** units for the distance calculations. Available are: `Centimeters`, `Meters` & `Kilometers`. Default is `Meters`.

### Null or error handling

**Data**: The full input dataset with the addition of the columns `distanceMoved` and `distanceMovedDetails` (the latter containing the information of type of distance measured, time interval and units) is returned for further use in a next App and cannot be empty.