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

```perl6
roc-functions('FunctionInterpretations')
```

```perl6
say roc-functions('FPR');
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

Here is a sample of the dataset:

```perl6
use Data::Reshapers;
to-pretty-table(@dfRandomLabels.pick(6))
```

Here we make the corresponding ROC hash-map:

```perl6
to-roc-hash('true', 'false', @dfRandomLabels.map({$_<Actual>}), @dfRandomLabels.map({$_<Predicted>}))
```

### Multiple ROC records

Here we make random dataset with entries that associated with a certain threshold parameter with three unique values:

```perl6
my @dfRandomLabels2 = random-tabular-dataset(200, <Threshold Actual Predicted>, generators=>{Threshold => (0.2, 0.4, 0.6), Actual => <true false>, Predicted => <true false>});
records-summary(@dfRandomLabels2)
```

**Remark:** Threshold parameters are typically used while tuning Machine Learning (ML) classifiers.

Here we group the rows of the dataset by the unique threshold values:

```perl6
my %groups = group-by(@dfRandomLabels2, 'Threshold');
records-summary(%groups)
```

Here we find and print the ROC records (hash-maps) for each unique threshold value:

```perl6
my @rocs = do for %groups.kv -> $k, $v { 
  to-roc-hash('true', 'false', $v.map({$_<Actual>}), $v.map({$_<Predicted>})) 
}
.say for @rocs;
```

### Application of ROC functions

Here we define a list of ROC functions:

```perl6
my @funcs = (&PPV, &NPV, &TPR, &ACC, &SPC, &MCC);
```

Here we apply each ROC function to each of the ROC records obtained above:

```perl6
my @rocRes = @rocs.map( -> $r { @funcs.map({ $_.name => $_($r) }).Hash });
say to-pretty-table(@rocRes);
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
