use v6.d;

unit module ML::ROCFunctions;

#------------------------------------------------------------
# ROC predicates
#------------------------------------------------------------

sub is-roc-associate($obj) is export {
    given $obj {
        when Associative { ($obj.keys (&) <TruePositive FalsePositive TrueNegative FalseNegative>).elems == 4 }
        default { False }
    }
}

#------------------------------------------------------------
# ROCs
#------------------------------------------------------------

proto sub TPR(%rocAssoc) is export {*}
multi sub TPR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive>) / (%rocAssoc<TruePositive> + %rocAssoc<FalseNegative>);
}
multi sub TPR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ TPR($_) }).Array
}

proto sub SPC(%rocAssoc) is export {*}
multi sub SPC(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TrueNegative>) / (%rocAssoc<FalsePositive> + %rocAssoc<TrueNegative>);
}
multi sub SPC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ SPC($_) }).Array
}

proto sub PPV(%rocAssoc) is export {*}
multi sub PPV(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive>) / (%rocAssoc<TruePositive> + %rocAssoc<FalsePositive>);
}
multi sub PPV(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ PPV($_) }).Array
}

proto sub NPV(%rocAssoc) is export {*}
multi sub NPV(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TrueNegative>) / (%rocAssoc<TrueNegative> + %rocAssoc<FalseNegative>);
}
multi sub NPV(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ NPV($_) }).Array
}

proto sub FPR(%rocAssoc) is export {*}
multi sub FPR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalsePositive>) / (%rocAssoc<FalsePositive> + %rocAssoc<TrueNegative>);
}
multi sub FPR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FPR($_) }).Array
}

proto sub FDR(%rocAssoc) is export {*}
multi sub FDR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalsePositive>) / (%rocAssoc<FalsePositive> + %rocAssoc<TruePositive>);
}
multi sub FDR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FDR($_) }).Array
}

proto sub FNR(%rocAssoc) is export {*}
multi sub FNR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalseNegative>) / (%rocAssoc<FalseNegative> + %rocAssoc<TruePositive>);
}
multi sub FNR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FNR($_) }).Array
}

proto sub ACC(%rocAssoc) is export {*}
multi sub ACC(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive> + %rocAssoc<TrueNegative>) / ([+] %rocAssoc.values);
}
multi sub ACC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ ACC($_) }).Array
}

proto sub FOR(%rocAssoc) is export {*}
multi sub FOR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    1 - NPV(%rocAssoc)
}
multi sub FOR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FOR($_) }).Array
}

proto sub F1(%rocAssoc) is export {*}
multi sub F1(%rocAssoc where is-roc-associate(%rocAssoc)) {
    2 * PPV(%rocAssoc) * TPR(%rocAssoc) / (PPV(%rocAssoc) + TPR(%rocAssoc));
}
multi sub F1(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ F1($_) }).Array
}

sub AUROC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) is export {
        my @fprs = @rocs.map({ FPR($_) }).Array.prepend(0).append(1);
        my @tprs = @rocs.map({ TPR($_) }).Array.prepend(0).append(1);

        my $sum = 0;
        for 0..^(@fprs.elems-1) -> $i {
                $sum += (@fprs[$i+1] - @fprs[$i]) * (@tprs[$i] + (@tprs[$i+1] - @tprs[$i]) / 2)
        }
        return $sum;
}

proto sub MCC(%rocAssoc) is export {*}
multi sub MCC(%rocAssoc where is-roc-associate(%rocAssoc)) {
        my ($tp, $tn, $fp, $fn);
        my ($tpfp, $tpfn, $tnfp, $tnfn);

        ($tp, $tn, $fp, $fn) = (&TPR, &SPC, &FPR, &FNR).map({ $_(%rocAssoc) });
        ($tpfp, $tpfn, $tnfp, $tnfn) = ($tp + $fp, $tp + $fn, $tn + $fp, $tn + $fn).map({ $_ == 0 ?? 1 !! $_ });

        ($tp * $tn - $fp * $fn) / sqrt( $tpfp * $tpfn * $tnfp * $tnfn )
}
multi sub MCC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ MCC($_) }).Array
}


#------------------------------------------------------------
# ROC acronyms
#------------------------------------------------------------

my %ROCAcronyms =
        'TPR' => 'true positive rate', 'TNR' => 'true negative rate', 'SPC' => 'specificity',
        'PPV' => 'positive predictive value', 'NPV' => 'negative predictive value', 'FPR' => 'false positive rate',
        'FDR' => 'false discovery rate', 'FNR' => 'false negative rate', 'ACC' => 'accuracy',
        'AUROC' => 'area under the ROC curve', 'FOR' => 'false omission rate', 'F1' => 'F1 score',
        'MCC' => 'Matthews correlation coefficient', 'Recall' => 'same as TPR', 'Precision' => 'same as PPV',
        'Accuracy' => 'same as ACC', 'Sensitivity' => 'same as TPR';

sub roc-accronyms-dictionary() is export {
    %ROCAcronyms
}


#------------------------------------------------------------
# ROC functions
#------------------------------------------------------------

my %ROCFunctions =
        'TPR' => &TPR, 'TNR' => &SPC, 'SPC' => &SPC, 'PPV' => &PPV, 'NPV' => &NPV, 'FPR' => &FPR, 'FDR' => &FDR,
        'FNR' => &FNR, 'ACC' => &ACC, 'AUROC' => &AUROC, 'FOR' => &FOR, 'F1' => &F1, 'MCC' => &MCC, 'Recall' => &TPR,
        'Sensitivity' => &TPR, 'Precision' => &PPV, 'Accuracy' => &ACC,
        'Specificity' => &SPC, 'FalsePositiveRate' => &FPR,
        'TruePositiveRate' => &TPR, 'FalseNegativeRate' => &FNR, 'TrueNegativeRate' => &SPC,
        'FalseDiscoveryRate' => &FDR, 'FalseOmissionRate' => &FOR, 'F1Score' => &F1, 'AreaUnderROCCurve' => &AUROC,
        'MatthewsCorrelationCoefficient' => &MCC;


proto roc-functions($spec) is export {*}

multi sub roc-functions(Str $spec) {
    given $spec.lc {
        when 'Methods'.lc { <FunctionInterpretations FunctionNames Functions Methods Properties> }
        when 'Properties'.lc { roc-functions('methods') }
        when 'FunctionNames'.lc { %ROCAcronyms.keys }
        when 'FunctionInterpretations'.lc { %ROCAcronyms }
        when 'FunctionsAssociation'.lc { %ROCFunctions }
        when 'Functions'.lc { %ROCFunctions.values.unique }
        default { %ROCFunctions{$spec} }
    }
}

multi sub roc-functions(@spec where @spec.all ~~ Str) {
    %ROCFunctions{|@spec}
}