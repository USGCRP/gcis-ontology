#!/bin/bash -e

status=0

n=1
tests=3

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

riot --validate ./gcis.ttl > /tmp/errs
if grep -q -i error /tmp/errs; then
    cat /tmp/errs
    bail_out "gcis.ttl errors"
else
    ok "valid gcis.ttl"
fi

cd t
cat ./data/*.ttl > /tmp/triples.ttl

for i in ./sparql/*.sparql; do
    base=`basename $i .sparql`
    tdbquery --mem=/tmp/triples.ttl --file=$i > /tmp/$base.txt
    if [ ! -e ./results/$base.txt ]; then
        diagcat /tmp/$base.txt
        pwd
        bail_out "missing ./results/$base.txt"
    fi
    if diff /tmp/$base.txt ./results/$base.txt > /tmp/errs;
    then ok $base 
    else
         not_ok $base;
         diagcat /tmp/errs;
    fi
done

let "n--"
if [ $n -ne $tests ]; then
    echo "# Wrong number of tests: $n vs $tests"
    status=1
fi
exit $status

