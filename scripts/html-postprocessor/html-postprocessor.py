__author__ = 'szednik'

import sys
from bs4 import BeautifulSoup


def get_ref(text):
    if '#' in text:
        return text.strip()[text.find('#'):]
    else:
        return '#' + text.strip()[text.rfind('/') + 1:]


def get_id(text):
    if '#' in text:
        return text.strip()[text.find('#') + 1:]
    else:
        return text.strip()[text.rfind('/') + 1:]


def print_usage():
    print("usage: " + sys.argv[0] + " <infile> [<outfile>]")


urls = ["http://data.globalchange.gov/gcis.owl",
        "http://www.w3.org/2009/08/skos-reference/skos.rdf#",
        "http://xmlns.com/foaf/0.1/"]


def process(infile, outfile):
    with open(infile, "r") as html:
        soup = BeautifulSoup(html, 'html5lib')

        # for all anchor tags that have a title attribute whose value contains a substring from urls
        for link in [link for link in soup.find_all('a')
                     if link.get('href') is not None
                     and link.get('title') is not None
                     and any(url in link.get('title') for url in urls)]:
            # update the anchor tag's href attribute based on ref extracted from the title attribute
            link['href'] = get_ref(link.get("title"))

        # for all divs that have a child anchor tag with a name attribute whose values contains a substring from urls
        for div in [div for div in soup.find_all('div')
                    if div.get('id') is not None
                    and div.a is not None
                    and div.a.get('name') is not None
                    and any(url in div.a.get('name') for url in urls)]:
            # update the div id based on an id extracted from the child anchor tag's name attribute
            div['id'] = get_id(div.a["name"])

        with open(outfile, "w") as out:
            out.write(str(soup))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print_usage()
        exit()

    _infile = sys.argv[1]
    _outfile = sys.argv[2] if len(sys.argv) > 2 else "out.html"
    process(_infile, _outfile)
