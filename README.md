# ML::ROCFunctions

This repository has the code of a Raku package for Receiver Operating Characteristic (ROC) functions.

The ROC framework is used for analysis and tuning of binary classifiers, [Wk1]. 
(The classifiers are assumed to classify into a positive/true label or a negative/false label. )

For computational introduction to ROC utilization (in Mathematica) see the article
["Basic example of using ROC with Linear regression"](https://mathematicaforprediction.wordpress.com/2016/10/12/basic-example-of-using-roc-with-linear-regression/),
[AA1].

The examples below use the packages 
["Data::Generators"](https://raku.land/cpan:ANTONOV/Data::Generators), 
["Data::Reshapers"](https://raku.land/cpan:ANTONOV/Data::Reshapers), and 
["Data::Summarizers"](https://raku.land/cpan:ANTONOV/Data::Summarizers), described in the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA2].

-------

## Installation

Via zef-ecosystem:

```shell
zef install ML::ROCFunctions
```

From GitHub:

```shell
zef install https://github.com/antononcube/Raku-ML-ROCFunctions
```


-------

## Usage examples

### Properties

Here are some retrieval functions:

```perl6
use ML::ROCFunctions;
say roc-functions('properties');
say roc-functions('FPR');
```
```
# (FunctionInterpretations FunctionNames Functions Methods Properties)
# &FPR
```

### Single ROC record

Here we generate a random "dataset" with columns "Actual" and "Predicted" that have the values "true" and "false" 
and show the summary:

```perl6
use Data::Generators;
use Data::Summarizers;
my @dfRandomLabels = random-tabular-dataset(200, <Actual Predicted>, generators=>{Actual => <true false>, Predicted => <true false>});
records-summary(@dfRandomLabels)
```
```
# +--------------+--------------+
# | Predicted    | Actual       |
# +--------------+--------------+
# | false => 101 | true  => 101 |
# | true  => 99  | false => 99  |
# +--------------+--------------+
```

Here is a sample of the dataset:

```perl6
use Data::Reshapers;
to-pretty-table(@dfRandomLabels.pick(6))
```
```
# +-----------+--------+
# | Predicted | Actual |
# +-----------+--------+
# |   false   |  true  |
# |   false   |  true  |
# |    true   |  true  |
# |    true   | false  |
# |    true   | false  |
# |   false   | false  |
# +-----------+--------+
```

Here we make the corresponding ROC hash-map:

```perl6
to-roc-hash('true', 'false', @dfRandomLabels.map({$_<Actual>}), @dfRandomLabels.map({$_<Predicted>}))
```
```
# {FalseNegative => 53, FalsePositive => 51, TrueNegative => 48, TruePositive => 48}
```

### Multiple ROC records

Here we make random dataset with entries that associated with a certain threshold parameter with three unique values:

```perl6
my @dfRandomLabels2 = random-tabular-dataset(200, <Threshold Actual Predicted>, generators=>{Threshold => (0.2, 0.4, 0.6), Actual => <true false>, Predicted => <true false>});
records-summary(@dfRandomLabels2)
```
```
# +--------------+--------------+-----------------+
# | Predicted    | Actual       | Threshold       |
# +--------------+--------------+-----------------+
# | true  => 107 | false => 106 | Min    => 0.2   |
# | false => 93  | true  => 94  | 1st-Qu => 0.2   |
# |              |              | Mean   => 0.408 |
# |              |              | Median => 0.4   |
# |              |              | 3rd-Qu => 0.6   |
# |              |              | Max    => 0.6   |
# +--------------+--------------+-----------------+
```

**Remark:** Threshold parameters are typically used while tuning Machine Learning (ML) classifiers.

Here we group the rows of the dataset by the unique threshold values:

```perl6
my %groups = group-by(@dfRandomLabels2, 'Threshold');
records-summary(%groups)
```
```
# summary of 0.6 =>
# +-------------+-------------+---------------+
# | Actual      | Predicted   | Threshold     |
# +-------------+-------------+---------------+
# | true  => 38 | true  => 40 | Min    => 0.6 |
# | false => 36 | false => 34 | 1st-Qu => 0.6 |
# |             |             | Mean   => 0.6 |
# |             |             | Median => 0.6 |
# |             |             | 3rd-Qu => 0.6 |
# |             |             | Max    => 0.6 |
# +-------------+-------------+---------------+
# summary of 0.4 =>
# +-------------+---------------+-------------+
# | Predicted   | Threshold     | Actual      |
# +-------------+---------------+-------------+
# | true  => 31 | Min    => 0.4 | false => 32 |
# | false => 29 | 1st-Qu => 0.4 | true  => 28 |
# |             | Mean   => 0.4 |             |
# |             | Median => 0.4 |             |
# |             | 3rd-Qu => 0.4 |             |
# |             | Max    => 0.4 |             |
# +-------------+---------------+-------------+
# summary of 0.2 =>
# +---------------+-------------+-------------+
# | Threshold     | Actual      | Predicted   |
# +---------------+-------------+-------------+
# | Min    => 0.2 | false => 38 | true  => 36 |
# | 1st-Qu => 0.2 | true  => 28 | false => 30 |
# | Mean   => 0.2 |             |             |
# | Median => 0.2 |             |             |
# | 3rd-Qu => 0.2 |             |             |
# | Max    => 0.2 |             |             |
# +---------------+-------------+-------------+
```

Here we find and print the ROC records (hash-maps) for each unique threshold value:

```perl6
my @rocs = do for %groups.kv -> $k, $v { 
  to-roc-hash('true', 'false', $v.map({$_<Actual>}), $v.map({$_<Predicted>})) 
}
.say for @rocs;
```
```
# {FalseNegative => 20, FalsePositive => 22, TrueNegative => 14, TruePositive => 18}
# {FalseNegative => 8, FalsePositive => 11, TrueNegative => 21, TruePositive => 20}
# {FalseNegative => 14, FalsePositive => 22, TrueNegative => 16, TruePositive => 14}
```

### Application of ROC functions

Here we define a list of ROC functions:

```perl6
my @funcs = (&PPV, &NPV, &TPR, &ACC, &SPC, &MCC);
```
```
# [&PPV &NPV &TPR &ACC &SPC &MCC]
```

Here we apply each ROC function to each of the ROC records obtained above:

```perl6
my @rocRes = @rocs.map( -> $r { @funcs.map({ $_.name => $_($r) }).Hash });
say to-pretty-table(@rocRes);
```
```
# +----------+----------+----------+----------+-----------+----------+
# |   TPR    |   SPC    |   PPV    |   NPV    |    MCC    |   ACC    |
# +----------+----------+----------+----------+-----------+----------+
# | 0.473684 | 0.388889 | 0.450000 | 0.411765 | -0.137924 | 0.432432 |
# | 0.714286 | 0.656250 | 0.645161 | 0.724138 |  0.371161 | 0.683333 |
# | 0.500000 | 0.421053 | 0.388889 | 0.533333 | -0.079195 | 0.454545 |
# +----------+----------+----------+----------+-----------+----------+
```

-------

## References

### Articles 

[Wk1] Wikipedia entry, ["Receiver operating characteristic"](https://en.wikipedia.org/wiki/Receiver_operating_characteristic).

[AA1] Anton Antonov,
["Basic example of using ROC with Linear regression"](https://mathematicaforprediction.wordpress.com/2016/10/12/basic-example-of-using-roc-with-linear-regression/),
(2016),
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).


[AA2] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

### Packages 

[AAp1] Anton Antonov,
[ROCFunctions Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/ROCFunctions.m),
(2016-2022),
[MathematicaForPrediction at GitHub/antononcube](https://github.com/antononcube/MathematicaForPrediction/).

[AAp2] Anton Antonov,
[ROCFunctions R package](https://github.com/antononcube/R-packages/tree/master/ROCFunctions),
(2021),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

[AAp1] Anton Antonov,
