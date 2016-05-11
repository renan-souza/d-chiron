## Risers Fatigue Analysis synthetic workflow

This is our case study. It is based on a real workflow used in the oil and gas domain. The RFA workflow is composed of seven activites that receive input tuples, perform complex calculations based on them, and transform tuples into resulting output tuples.

![alt text](https://raw.githubusercontent.com/vssousa/d-chiron/master/images/rfa-image.png "Risers Fatigue Analysis workflow")

* Uncompress Input dataset - split one tuple into many
* Pre-processing - map
* Analyze Risers - map
* Calculate wear and tear - filter
* Analyze Position - filter
* Join results - join
* Compress results - reduce tuples
