#!/bin/bash -e

status=0

n=1

# count tests
tests=`find ./t/sparql/ -name *.sparql | wc -l`
# 1 more for gcis.ttl
let "tests++"

echo "1..$tests"

ok() {
    echo "ok $n - $1"
    let "n++"
}

not_ok() {
    echo "not ok $n - $1"
    let "n++"
    status=1
}

diagcat() {
    echo "# $1:"
    cat $1 | sed 's/^/# /'
}

bail_out() {
    echo "# $1: bailing out"
    exit 1;
}

cmp_file() {
   if diff -Z $1 $2 > /tmp/errs;
        then ok $3
   else
         not_ok $3;
         diagcat /tmp/errs;
   fi
}

# Validate.
riot --validate ./gcis.ttl > /tmp/errs
if grep -q -i error /tmp/errs; then
    cat /tmp/errs
    bail_out "gcis.ttl errors"
else
    ok "valid gcis.ttl"
fi

# Test.
cd t
for i in ./sparql/*.sparql; do
    base=`basename $i .sparql`

    # Concatenate.
    if [ -e ./data/$base.ttl' ]; then
        find t/data -name './data/$base.ttl' | xargs cat ./data/gcis.ttl > /tmp/triples.ttl
    else
        not_ok "missing data/$base.txt"
        continue
    fi

    if [ -e ./results/$base.txt ]; then
        tdbquery --mem=/tmp/triples.ttl --file=$i > /tmp/$base.txt
        cmp_file /tmp/$base.txt ./results/$base.txt $base.sparql
    elif [ -e ./results/$base.csv ]; then
        tdbquery --mem=/tmp/triples.ttl --file=$i --results csv > /tmp/$base.csv
        cmp_file /tmp/$base.csv ./results/$base.csv $base.sparql
    else
        not_ok "missing results/$base.txt or $base.csv"
        tdbquery --mem=/tmp/triples.ttl --file=$i > /tmp/$base.txt
        diagcat /tmp/$base.txt
        tdbquery --mem=/tmp/triples.ttl --file=$i --results csv > /tmp/$base.csv
        diagcat /tmp/$base.csv
    fi
done

# Report total.
let "n--"
if [ $n -ne $tests ]; then
    echo "# Wrong number of tests: $n vs $tests"
    status=1
fi
exit $status

