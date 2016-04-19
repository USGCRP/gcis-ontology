
import pandas
import urllib.parse
from rdflib import RDF, RDFS, XSD, Graph, URIRef, Literal, Namespace

vocab_uri = "http://data.globalchange.gov/vocab/human-health"

SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
DCT = Namespace("http://purl.org/dc/terms/")
GCIS = Namespace("http://data.globalchange.gov/gcis.owl#")

g = Graph()
g.bind("skos", SKOS)
g.bind("dcterms", DCT)

vocab = g.resource(URIRef(vocab_uri))
vocab.add(RDF.type, SKOS.ConceptScheme)
vocab.add(DCT.title, Literal("Human Health Vocabulary"))

csv_file = "TermRelationship_vector_borne_12_22.xlsx"
df = pandas.read_excel(csv_file, sheetname='Term')

for index, row in df.iterrows():
    if row["Term"] is not pandas.np.nan:

        term = row["Term"].strip()
        uri = vocab_uri+"/concept/"+urllib.parse.quote_plus(term)

        concept = g.resource(URIRef(uri))
        concept.add(RDF.type, SKOS.Concept)
        concept.add(SKOS.prefLabel, Literal(term))
        concept.add(SKOS.inScheme, vocab)

        if row["Definition"] is not pandas.np.nan:
            definition = row["Definition"].strip()
            concept.add(SKOS.definition, Literal(definition))

        if row["extURI"] is not pandas.np.nan:
            source = row["extURI"].strip()
            concept.add(DCT.source, URIRef(source))

df = pandas.read_excel(csv_file, sheetname='SubPredObj')
for index, row in df.iterrows():
    if row["Predicate"] is not pandas.np.nan:

        _subject = vocab_uri + "/concept/" + urllib.parse.quote_plus(row["Subject"].strip())
        _object = vocab_uri + "/concept/" + urllib.parse.quote_plus(row["Object"].strip())

        if row["Predicate"] == "skos:narrower":
            g.add((URIRef(_subject), SKOS.narrower, URIRef(_object)))
        else:
            g.add((URIRef(_subject), SKOS.related, URIRef(_object)))

g.serialize("human-health.ttl", format="turtle")
