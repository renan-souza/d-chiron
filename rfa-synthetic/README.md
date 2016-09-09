## Risers Fatigue Analysis synthetic workflow

This is our case study. It is based on a real workflow used in the oil and gas domain. The RFA workflow is composed of seven activites that receive input tuples, perform complex calculations based on them, and transform tuples into resulting output tuples.

![alt text](https://raw.githubusercontent.com/renanfrancisco/d-chiron/master/images/rfa-image.png "Risers Fatigue Analysis workflow")

* Data Gathering - split one tuple into many tuples
* Preprocessing - map
* Stress Analysis - map
* Stress Critical Case Selection - filter
* Curvature Critical Case Selection - filter
* Calculate Fatigue Life - join
* Compress Results - reduce tuples
