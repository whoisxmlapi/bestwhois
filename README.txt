	   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	    BESTWHOIS - A COMMAND-LINE WHOIS-LIKE CLIENT FOR
	    THE WHOIS AND WHOIS HISTORY APIS BY WHOISXML API
				  INC.

			   WhoisXML API, Inc.
	   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


			  v 0.0.4, 2021.11.17.


Table of Contents
─────────────────

1 About
2 Installation
.. 2.1 Prerequisites
.. 2.2 Running the program
3 Quick start
4 Specifications
.. 4.1 Command-line options
.. 4.2 Output
.. 4.3 Return codes





1 About
═══════

  The 'bestwhois' command-line utility make queries through the API
  service provided by WhoisXML API, Inc. It is intended as a replacement
  of the standard 'whois' command for domain and IP WHOIS queries, to
  provide accurate queries from our WHOIS database via the WHOIS API
  ([https://whoisapi.whoisxmlapi.com]). In addition it can yield
  historic WHOIS records for domains by invoking the WHOIS history API
  ([https://whois-history-api.whoisxmlapi.com]).

  By default it gives a pretty-printed human-readable JSON output, which
  is at least as readable and definitely more structured as the standard
  textual output of WHOIS. Optionally it can also print a textual output
  which is closer to usual WHOIS.

  The use of the utility requires a subscription to the Whois API, see
  its details at [https://whoisxmlapi.com]. A free subscription is also
  available.


[https://whoisxmlapi.com] https://whoisapi.whoisxmlapi.com


2 Installation
══════════════

2.1 Prerequisites
─────────────────

  • The program is written in series 3 Python, so it has to be installed
  on your system to run. It has been tested with version >= 3.6.
  • It depends also on the pygments, argparse, and urllib (or urllib2)
    packages. You may install these with the package manager of your OS
    (e.g. apt), or using Python's package manager, 'pip', by doing
  ┌────
  │ pip3 install pygments
  └────
  in your shell or Windows command line. If you want to query for
  domains with national characters with Unicode encoding, you also need
  the `idna' package:
  ┌────
  │ pip3 install idna
  └────


2.2 Running the program
───────────────────────

  *Windows users* have to rename the file "bestwhois" to "bestwhois.py"
  ┌────
  │ move bestwhois bestwhois.py
  └────
  and use it as bestwhois.py. When first running, it has to associated
  with Python in this environment.

  Apart from this, all you need is a valid API key which can be obtained
  after registration.  You may specify this for the program in various
  ways:
  • With the –api-key= command-line option
  • Writing the API key single-line into a text file (named rc file in
    what follows), and specifying the location with the –rcfile= option
  • Naming the rc file ".bestwhoisrc", and putting it to your home
    directory or next to the script. We recommend to withdraw read
    permissions from other files on this.
  • Putting the rc file to /etc/bestwhoisrc .

  The program currently uses the same API key for both the WHOIS API and
  the WHOIS History API. If your key is not valid for either of these,
  an error will produced.


3 Quick start
═════════════

  Having a proper rc file, the program should simply run from
  command-line. You may want to put it to some location in the path,
  e.g. to /usr/local/bin on UNIX-flavor systems. Just try
  ┌────
  │ bestwhois domainwhoisdatabase.com
  └────
  (Or
  ┌────
  │ bestwhois.py domainwhoisdatabase.com
  └────
  on Windows).

  A help is available with the –help option.

  Some further examples:
  • A simple WHOIS query with text output:
  ┌────
  │ bestwhois --text domainwhoisdatabase.com
  └────
  • Simple WHOIS query with raw text fields fully included:
  ┌────
  │ bestwhois --fullrawtext domainwhoisdatabase.com
  └────
  • IP WHOIS query with non-colored output:
  ┌────
  │ bestwhois --nocolor 104.27.154.235
  └────
  • Full history query:
  ┌────
  │ bestwhois --history domainwhoisdatabase.com
  └────
  • History query with date restrictions:
  ┌────
  │ bestwhois domainwhoisdatabase.com --created-date-from 2000-01-01 --expired-date-to 2020-01-01
  └────
  • Query a domain with national characters (the two lines are
    equivalent):
  ┌────
  │ bestwhois москва.рф 
  │ bestwhois xn--80adxhks.xn--p1ai
  └────


4 Specifications
════════════════

4.1 Command-line options
────────────────────────

  A full list of command-line options can be obtained by invoking the
  program with the –help option.

  Note: the options marked with "(history)" in their description imply
  the use of the WHOIS History API instead of the WHOIS API.


4.2 Output
──────────

  The output consists of parsed WHOIS records as specified by the
  command-line options. The default is a colorized JSON-like text. On
  Windows consoles, coloring is not supported.

  If there are no WHOIS records in the output of the API, the output of
  the API is printed.


4.3 Return codes
────────────────

  `0'
        Normal termination.
  `1'
        Error in the API call. Typical reasons: bad API key, nonexistent
        domain name in the History API.
  `2'
        No WHOIS records in the reply.
  `3'
        Tried to query a domain with Unicode national characters and the
        `idna' package is not installed.
