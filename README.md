# ML::ROCFunctions

This repository has the code of a Raku package for 
[Receiver Operating Characteristic (ROC)](https://en.wikipedia.org/wiki/Receiver_operating_characteristic) 
functions.

The ROC framework is used for analysis and tuning of binary classifiers, [Wk1]. 
(The classifiers are assumed to classify into a positive/true label or a negative/false label. )

For computational introduction to ROC utilization (in Mathematica) see the article
["Basic example of using ROC with Linear regression"](https://mathematicaforprediction.wordpress.com/2016/10/12/basic-example-of-using-roc-with-linear-regression/),
[AA1].

This package has counterparts in Mathematica, Python, and R. See [AAp1, AAp2, AAp3].

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
```
```
# (FunctionInterpretations FunctionNames Functions Methods Properties)
```

```perl6
roc-functions('FunctionInterpretations')
```
```
# {ACC => accuracy, AUROC => area under the ROC curve, Accuracy => same as ACC, F1 => F1 score, FDR => false discovery rate, FNR => false negative rate, FOR => false omission rate, FPR => false positive rate, MCC => Matthews correlation coefficient, NPV => negative predictive value, PPV => positive predictive value, Precision => same as PPV, Recall => same as TPR, SPC => specificity, Sensitivity => same as TPR, TNR => true negative rate, TPR => true positive rate}
```

```perl6
say roc-functions('FPR');
```
```
# &FPR
```

### Single ROC record

**Definition:** A ROC record (ROC-hash or ROC-hash-map) is an object of type `Associative` that has the keys:
"FalseNegative", "FalsePositive", "TrueNegative", "TruePositive". Here is an example:

```{perl6, eval=FALSE}
{FalseNegative => 50, FalsePositive => 51, TrueNegative => 60, TruePositive => 39}
```

Here we generate a random "dataset" with columns "Actual" and "Predicted" that have the values "true" and "false" 
and show the summary:

```perl6
use Data::Generators;
use Data::Summarizers;
my @dfRandomLabels = 
        random-tabular-dataset(200, <Actual Predicted>, 
        generators => {Actual => <true false>, 
                       Predicted => <true false>});
records-summary(@dfRandomLabels)
```
```
# +--------------+--------------+
# | Actual       | Predicted    |
# +--------------+--------------+
# | false => 107 | false => 102 |
# | true  => 93  | true  => 98  |
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
# |    true   | false  |
# |   false   |  true  |
# |   false   |  true  |
# |    true   | false  |
# |   false   | false  |
# +-----------+--------+
```

Here we make the corresponding ROC hash-map:

```perl6
to-roc-hash('true', 'false', @dfRandomLabels.map({$_<Actual>}), @dfRandomLabels.map({$_<Predicted>}))
```
```
# {FalseNegative => 49, FalsePositive => 54, TrueNegative => 53, TruePositive => 44}
```

### Multiple ROC records

Here we make random dataset with entries that associated with a certain threshold parameter with three unique values:

```perl6
my @dfRandomLabels2 = 
        random-tabular-dataset(200, <Threshold Actual Predicted>, 
                generators => {Threshold => (0.2, 0.4, 0.6), 
                               Actual => <true false>, 
                               Predicted => <true false>});
records-summary(@dfRandomLabels2)
```
```
# +-----------------+--------------+--------------+
# | Threshold       | Predicted    | Actual       |
# +-----------------+--------------+--------------+
# | Min    => 0.2   | true  => 104 | false => 101 |
# | 1st-Qu => 0.2   | false => 96  | true  => 99  |
# | Mean   => 0.394 |              |              |
# | Median => 0.4   |              |              |
# | 3rd-Qu => 0.6   |              |              |
# | Max    => 0.6   |              |              |
# +-----------------+--------------+--------------+
```

**Remark:** Threshold parameters are typically used while tuning Machine Learning (ML) classifiers.

Here we group the rows of the dataset by the unique threshold values:

```perl6
my %groups = group-by(@dfRandomLabels2, 'Threshold');
records-summary(%groups)
```
```
# summary of 0.6 =>
# +-------------+---------------+-------------+
# | Predicted   | Threshold     | Actual      |
# +-------------+---------------+-------------+
# | true  => 32 | Min    => 0.6 | true  => 32 |
# | false => 25 | 1st-Qu => 0.6 | false => 25 |
# |             | Mean   => 0.6 |             |
# |             | Median => 0.6 |             |
# |             | 3rd-Qu => 0.6 |             |
# |             | Max    => 0.6 |             |
# +-------------+---------------+-------------+
# summary of 0.4 =>
# +-------------+-------------+---------------+
# | Predicted   | Actual      | Threshold     |
# +-------------+-------------+---------------+
# | false => 41 | true  => 41 | Min    => 0.4 |
# | true  => 39 | false => 39 | 1st-Qu => 0.4 |
# |             |             | Mean   => 0.4 |
# |             |             | Median => 0.4 |
# |             |             | 3rd-Qu => 0.4 |
# |             |             | Max    => 0.4 |
# +-------------+-------------+---------------+
# summary of 0.2 =>
# +---------------+-------------+-------------+
# | Threshold     | Predicted   | Actual      |
# +---------------+-------------+-------------+
# | Min    => 0.2 | true  => 33 | false => 37 |
# | 1st-Qu => 0.2 | false => 30 | true  => 26 |
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
# {FalseNegative => 16, FalsePositive => 16, TrueNegative => 9, TruePositive => 16}
# {FalseNegative => 22, FalsePositive => 20, TrueNegative => 19, TruePositive => 19}
# {FalseNegative => 13, FalsePositive => 20, TrueNegative => 17, TruePositive => 13}
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
# +----------+----------+-----------+----------+----------+----------+
# |   ACC    |   SPC    |    MCC    |   TPR    |   PPV    |   NPV    |
# +----------+----------+-----------+----------+----------+----------+
# | 0.438596 | 0.360000 | -0.141393 | 0.500000 | 0.500000 | 0.360000 |
# | 0.475000 | 0.487179 | -0.049420 | 0.463415 | 0.487179 | 0.463415 |
# | 0.476190 | 0.459459 | -0.040574 | 0.500000 | 0.393939 | 0.566667 |
# +----------+----------+-----------+----------+----------+----------+
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

[AAp0] Anton Antonov,
[ML::ROCFunctions Raku package](https://github.com/antononcube/Raku-ML-ROCFunctions),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp1] Anton Antonov,
[ROCFunctions Mathematica package](https://github.com/antononcube/MathematicaForPrediction/blob/master/ROCFunctions.m),
(2016-2022),
[MathematicaForPrediction at GitHub/antononcube](https://github.com/antononcube/MathematicaForPrediction/).

[AAp2] Anton Antonov,
[ROCFunctions Python package](https://github.com/antononcube/Python-packages/tree/master/ROCFunctions),
(2022),
[Python-packages at GitHub/antononcube](https://github.com/antononcube/Python-packages).

[AAp3] Anton Antonov,
[ROCFunctions R package](https://github.com/antononcube/R-packages/tree/master/ROCFunctions),
(2021),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

[AAp4] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).
