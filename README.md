# ML::ROCFunctions

This repository has the code of a Raku package for 
[Receiver Operating Characteristic (ROC)](https://en.wikipedia.org/wiki/Receiver_operating_characteristic) 
functions.

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
# | true  => 109 | false => 110 |
# | false => 91  | true  => 90  |
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
# |  true  |    true   |
# |  true  |    true   |
# | false  |   false   |
# |  true  |    true   |
# |  true  |   false   |
# |  true  |   false   |
# +--------+-----------+
```

Here we make the corresponding ROC hash-map:

```perl6
to-roc-hash('true', 'false', @dfRandomLabels.map({$_<Actual>}), @dfRandomLabels.map({$_<Predicted>}))
```
```
# {FalseNegative => 57, FalsePositive => 38, TrueNegative => 53, TruePositive => 52}
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
# +---------------+--------------+--------------+
# | Threshold     | Predicted    | Actual       |
# +---------------+--------------+--------------+
# | Min    => 0.2 | true  => 104 | false => 103 |
# | 1st-Qu => 0.2 | false => 96  | true  => 97  |
# | Mean   => 0.4 |              |              |
# | Median => 0.4 |              |              |
# | 3rd-Qu => 0.6 |              |              |
# | Max    => 0.6 |              |              |
# +---------------+--------------+--------------+
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
# | Actual      | Threshold     | Predicted   |
# +-------------+---------------+-------------+
# | false => 35 | Min    => 0.6 | true  => 37 |
# | true  => 29 | 1st-Qu => 0.6 | false => 27 |
# |             | Mean   => 0.6 |             |
# |             | Median => 0.6 |             |
# |             | 3rd-Qu => 0.6 |             |
# |             | Max    => 0.6 |             |
# +-------------+---------------+-------------+
# summary of 0.2 =>
# +-------------+---------------+-------------+
# | Predicted   | Threshold     | Actual      |
# +-------------+---------------+-------------+
# | false => 33 | Min    => 0.2 | false => 34 |
# | true  => 31 | 1st-Qu => 0.2 | true  => 30 |
# |             | Mean   => 0.2 |             |
# |             | Median => 0.2 |             |
# |             | 3rd-Qu => 0.2 |             |
# |             | Max    => 0.2 |             |
# +-------------+---------------+-------------+
# summary of 0.4 =>
# +-------------+---------------+-------------+
# | Actual      | Threshold     | Predicted   |
# +-------------+---------------+-------------+
# | true  => 38 | Min    => 0.4 | false => 36 |
# | false => 34 | 1st-Qu => 0.4 | true  => 36 |
# |             | Mean   => 0.4 |             |
# |             | Median => 0.4 |             |
# |             | 3rd-Qu => 0.4 |             |
# |             | Max    => 0.4 |             |
# +-------------+---------------+-------------+
```

Here we find and print the ROC records (hash-maps) for each unique threshold value:

```perl6
my @rocs = do for %groups.kv -> $k, $v { 
  to-roc-hash('true', 'false', $v.map({$_<Actual>}), $v.map({$_<Predicted>})) 
}
.say for @rocs;
```
```
# {FalseNegative => 16, FalsePositive => 24, TrueNegative => 11, TruePositive => 13}
# {FalseNegative => 18, FalsePositive => 19, TrueNegative => 15, TruePositive => 12}
# {FalseNegative => 17, FalsePositive => 15, TrueNegative => 19, TruePositive => 21}
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
# +----------+-----------+----------+----------+----------+----------+
# |   ACC    |    MCC    |   NPV    |   TPR    |   PPV    |   SPC    |
# +----------+-----------+----------+----------+----------+----------+
# | 0.375000 | -0.239599 | 0.407407 | 0.448276 | 0.351351 | 0.314286 |
# | 0.421875 | -0.158958 | 0.454545 | 0.400000 | 0.387097 | 0.441176 |
# | 0.555556 |  0.111457 | 0.527778 | 0.552632 | 0.583333 | 0.558824 |
# +----------+-----------+----------+----------+----------+----------+
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

[AAp3] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).


