# gcis-ontology
[![Build Status](https://secure.travis-ci.org/USGCRP/gcis-ontology.png)](http://travis-ci.org/USGCRP/gcis-ontology)
Ontology for the Global Change Information System

Testing
=======
The unit tests for gcis-ontology can be run with the script run-tests.sh.

To add more tests, do the following:

    1. Add any data (.ttl files) into t/data/
    2. Add a SPARQL query into t/sparql/
    3. Add the expected output into t/results/

run-tests.sh will load all of the data in t/data, then iterate through
the queries in t/sparql and compare the output to the output in t/results.
If the output of the SPARQL query differs from what is in the corresponding
results file, the test will fail.  The format of the output of run-tests.sh
 follows the Test Anything Protocol (<http://testanything.org>).  A non-zero
exit code from run-tests.sh means that there was at least one test failure.

Testing directory structure:

    scripts/get-gcis-sources : Get sources for external ontologies
    t/data/ext : Turtle for the above
    t/data/gcis : Data from the live instance of GCIS
    t/sparql : SPARQL queries to run in the test suite
    t/results: Expected results corresponding to the SPARQL queries

