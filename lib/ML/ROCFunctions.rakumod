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

proto sub TPR($) is export {*}
multi sub TPR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive>) / (%rocAssoc<TruePositive> + %rocAssoc<FalseNegative>);
}
multi sub TPR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ TPR($_) }).Array
}

proto sub SPC($) is export {*}
multi sub SPC(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TrueNegative>) / (%rocAssoc<FalsePositive> + %rocAssoc<TrueNegative>);
}
multi sub SPC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ SPC($_) }).Array
}

proto sub TNR($) is export {*}
multi sub TNR(%rocAssoc where is-roc-associate(%rocAssoc)) {
   SPC(%rocAssoc)
}
multi sub TNR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ SPC($_) }).Array
}

proto sub PPV($) is export {*}
multi sub PPV(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive>) / (%rocAssoc<TruePositive> + %rocAssoc<FalsePositive>);
}
multi sub PPV(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ PPV($_) }).Array
}

proto sub NPV($) is export {*}
multi sub NPV(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TrueNegative>) / (%rocAssoc<TrueNegative> + %rocAssoc<FalseNegative>);
}
multi sub NPV(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ NPV($_) }).Array
}

proto sub FPR($) is export {*}
multi sub FPR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalsePositive>) / (%rocAssoc<FalsePositive> + %rocAssoc<TrueNegative>);
}
multi sub FPR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FPR($_) }).Array
}

proto sub FDR($) is export {*}
multi sub FDR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalsePositive>) / (%rocAssoc<FalsePositive> + %rocAssoc<TruePositive>);
}
multi sub FDR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FDR($_) }).Array
}

proto sub FNR($) is export {*}
multi sub FNR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<FalseNegative>) / (%rocAssoc<FalseNegative> + %rocAssoc<TruePositive>);
}
multi sub FNR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FNR($_) }).Array
}

proto sub ACC($) is export {*}
multi sub ACC(%rocAssoc where is-roc-associate(%rocAssoc)) {
    (%rocAssoc<TruePositive> + %rocAssoc<TrueNegative>) / ([+] %rocAssoc.values);
}
multi sub ACC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ ACC($_) }).Array
}

proto sub FOR($) is export {*}
multi sub FOR(%rocAssoc where is-roc-associate(%rocAssoc)) {
    1 - NPV(%rocAssoc)
}
multi sub FOR(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ FOR($_) }).Array
}

proto sub F1($) is export {*}
multi sub F1(%rocAssoc where is-roc-associate(%rocAssoc)) {
    2 * PPV(%rocAssoc) * TPR(%rocAssoc) / (PPV(%rocAssoc) + TPR(%rocAssoc));
}
multi sub F1(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) {
    @rocs.map({ F1($_) }).Array
}

sub AUROC(@rocs where ([&&] @rocs.map({ is-roc-associate($_) }))) is export {
    my @fprs = FPR(@rocs).Array.prepend(0).append(1);
    my @tprs = TPR(@rocs).Array.prepend(0).append(1);

    my @orderInds = @fprs.sort(:k);
    @fprs = @fprs[@orderInds];
    @tprs = @tprs[@orderInds];

    my $sum = 0;
    for 0 ..^ (@fprs.elems - 1) -> $i {
        $sum += (@fprs[$i + 1] - @fprs[$i]) * (@tprs[$i] + (@tprs[$i + 1] - @tprs[$i]) / 2)
    }
    return $sum;
}

proto sub MCC($) is export {*}
multi sub MCC(%rocAssoc where is-roc-associate(%rocAssoc)) {
    my ($tp, $tn, $fp, $fn);
    my ($tpfp, $tpfn, $tnfp, $tnfn);

    ($tp, $tn, $fp, $fn) = (&TPR, &SPC, &FPR, &FNR).map({ $_(%rocAssoc) });
    ($tpfp, $tpfn, $tnfp, $tnfn) = ($tp + $fp, $tp + $fn, $tn + $fp, $tn + $fn).map({ $_ == 0 ?? 1 !! $_ });

    ($tp * $tn - $fp * $fn) / sqrt($tpfp * $tpfn * $tnfp * $tnfn)
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

sub roc-acronyms-hash() is export {
    return %ROCAcronyms.clone;
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


proto roc-functions(|) is export {*}

multi sub roc-functions() {
    roc-functions('Functions')
}

multi sub roc-functions(Str $spec) {
    given $spec.lc {
        when 'Methods'.lc { <FunctionInterpretations FunctionNames Functions Methods Properties> }
        when 'Properties'.lc { roc-functions('methods') }
        when 'FunctionNames'.lc { roc-acronyms-hash().keys.List }
        when 'FunctionInterpretations'.lc { roc-acronyms-hash() }
        when 'FunctionsAssociation'.lc { %ROCFunctions }
        when 'Functions'.lc { %ROCFunctions.values.unique.List }
        default { %ROCFunctions{$spec} }
    }
}

multi sub roc-functions(@spec where @spec.all ~~ Str) {
    %ROCFunctions{|@spec}
}


#------------------------------------------------------------
# To ROC hash
#------------------------------------------------------------

proto to-roc-hash (|) is export {*}

multi sub to-roc-hash(Str :$sep = '-', :$true-label!, :$false-label!, :$actual!, :$predicted!) {
    to-roc-hash($true-label, $false-label, $actual, $predicted, :$sep);
}

multi sub to-roc-hash($true-label, $false-label, @actual-labels, @predicted-labels, Str :$sep = '-') {

    if @actual-labels.elems != @predicted-labels.elems {
        die 'The lengths of the second and third arguments are expected to be the same.';
    }

    # "Empty" ROC hash
    my %emptyROC = (($true-label, $false-label) X ($true-label, $false-label)).map({ $_.join($sep) }) X=> 0;

    # Derive TruePositive, FalsePositive, TrueNegative, and FalseNegative
    my %res = (@actual-labels Z @predicted-labels).categorize({ $_.join($sep) }).map({ $_.key => $_.value.elems });

    # Merge empty and derived hashes
    %res = %emptyROC, %res;

    return to-roc-hash($true-label, $false-label, %res, :$sep);
}

multi sub to-roc-hash($true-label, $false-label, %apf, Str :$sep = '-') {
    %(
        'TruePositive' => %apf{($true-label, $true-label).join($sep)},
        'FalsePositive' => %apf{($false-label, $true-label).join($sep)},
        'TrueNegative' => %apf{($false-label, $false-label).join($sep)},
        'FalseNegative' => %apf{($true-label, $false-label).join($sep)}
    )
}