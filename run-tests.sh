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
    cat $1 | sed 's/^/# /'
}

bail_out() {
    echo "# $1: bailing out"
    exit 1;
}

# Validate.
riot --validate ./gcis.ttl > /tmp/errs
if grep -q -i error /tmp/errs; then
    cat /tmp/errs
    bail_out "gcis.ttl errors"
else
    ok "valid gcis.ttl"
fi

# Concatenate.
find t/data -name '*.ttl' | xargs cat ./gcis.ttl > /tmp/triples.ttl

# Test.
cd t
for i in ./sparql/*.sparql; do
    base=`basename $i .sparql`
    tdbquery --mem=/tmp/triples.ttl --file=$i > /tmp/$base.txt
    if [ ! -e ./results/$base.txt ]; then
        diagcat /tmp/$base.txt
        not_ok "missing results/$base.txt"
    else
        if diff /tmp/$base.txt ./results/$base.txt > /tmp/errs;
        then ok $base.sparql
        else
             not_ok $base;
             diagcat /tmp/errs;
        fi
    fi
done

# Report total.
let "n--"
if [ $n -ne $tests ]; then
    echo "# Wrong number of tests: $n vs $tests"
    status=1
fi
exit $status

