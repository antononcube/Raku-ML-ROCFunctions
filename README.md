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
# | false => 101 | false => 100 |
# | true  => 99  | true  => 100 |
# +--------------+--------------+
```

Here is a sample of the dataset:

```perl6
use Data::Reshapers;
to-pretty-table(@dfRandomLabels.pick(6))
```
```
# +--------+-----------+
# | Actual | Predicted |
# +--------+-----------+
# | false  |    true   |
# |  true  |    true   |
# | false  |   false   |
# | false  |   false   |
# |  true  |    true   |
# | false  |   false   |
# +--------+-----------+
```

Here we make the corresponding ROC hash-map:

```perl6
to-roc-hash('true', 'false', @dfRandomLabels.map({$_<Actual>}), @dfRandomLabels.map({$_<Predicted>}))
```
```
# {FalseNegative => 52, FalsePositive => 51, TrueNegative => 49, TruePositive => 48}
```

### Multiple ROC records

Here we make random dataset with entries that associated with a certain threshold parameter with three unique values:

```perl6
my @dfRandomLabels2 = random-tabular-dataset(200, <Threshold Actual Predicted>, generators=>{Threshold => (0.2, 0.4, 0.6), Actual => <true false>, Predicted => <true false>});
records-summary(@dfRandomLabels2)
```
```
# +-----------------+--------------+--------------+
# | Threshold       | Predicted    | Actual       |
# +-----------------+--------------+--------------+
# | Min    => 0.2   | true  => 110 | true  => 103 |
# | 1st-Qu => 0.2   | false => 90  | false => 97  |
# | Mean   => 0.407 |              |              |
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
# +-------------+-------------+---------------+
# | Actual      | Predicted   | Threshold     |
# +-------------+-------------+---------------+
# | false => 37 | true  => 44 | Min    => 0.6 |
# | true  => 29 | false => 22 | 1st-Qu => 0.6 |
# |             |             | Mean   => 0.6 |
# |             |             | Median => 0.6 |
# |             |             | 3rd-Qu => 0.6 |
# |             |             | Max    => 0.6 |
# +-------------+-------------+---------------+
# summary of 0.4 =>
# +-------------+-------------+---------------+
# | Predicted   | Actual      | Threshold     |
# +-------------+-------------+---------------+
# | true  => 38 | true  => 44 | Min    => 0.4 |
# | false => 37 | false => 31 | 1st-Qu => 0.4 |
# |             |             | Mean   => 0.4 |
# |             |             | Median => 0.4 |
# |             |             | 3rd-Qu => 0.4 |
# |             |             | Max    => 0.4 |
# +-------------+-------------+---------------+
# summary of 0.2 =>
# +-------------+-------------+---------------+
# | Actual      | Predicted   | Threshold     |
# +-------------+-------------+---------------+
# | true  => 30 | false => 31 | Min    => 0.2 |
# | false => 29 | true  => 28 | 1st-Qu => 0.2 |
# |             |             | Mean   => 0.2 |
# |             |             | Median => 0.2 |
# |             |             | 3rd-Qu => 0.2 |
# |             |             | Max    => 0.2 |
# +-------------+-------------+---------------+
```

Here we find and print the ROC records (hash-maps) for each unique threshold value:

```perl6
my @rocs = do for %groups.kv -> $k, $v { 
  to-roc-hash('true', 'false', $v.map({$_<Actual>}), $v.map({$_<Predicted>})) 
}
.say for @rocs;
```
```
# {FalseNegative => 13, FalsePositive => 28, TrueNegative => 9, TruePositive => 16}
# {FalseNegative => 23, FalsePositive => 17, TrueNegative => 14, TruePositive => 21}
# {FalseNegative => 15, FalsePositive => 13, TrueNegative => 16, TruePositive => 15}
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
# +-----------+----------+----------+----------+----------+----------+
# |    MCC    |   TPR    |   PPV    |   SPC    |   ACC    |   NPV    |
# +-----------+----------+----------+----------+----------+----------+
# | -0.215545 | 0.551724 | 0.363636 | 0.243243 | 0.378788 | 0.409091 |
# | -0.071138 | 0.477273 | 0.552632 | 0.451613 | 0.466667 | 0.378378 |
# |  0.051793 | 0.500000 | 0.535714 | 0.551724 | 0.525424 | 0.516129 |
# +-----------+----------+----------+----------+----------+----------+
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
