#!/usr/bin/env python3
"""A command-line utility for WhoisXML API services
(c) WhoisXML API Inc. 2019.
"""

import sys
import os.path
import datetime
from argparse import ArgumentParser
import requests
import json
IDN = True
try:
    import idna
except:
    IDN = False
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter


#Static config
VERSION = "0.1.0"
MYNAME = sys.argv[0].replace('./', '')
RC_FILE_LOCS=[".bestwhoisrc", os.path.expanduser("~")+"/.bestwhoisrc", "/etc/bestwhois/bestwhoisrc"]

#Utility functions
def valid_date(s):
    """Function for validation of date arguments, but return strings"""
    try:
        _ =  datetime.datetime.strptime(s, "%Y-%m-%d")
        return(s)
    except ValueError:
        msg = "Not a valid date: '{0}'.".format(s)
        raise argparse.ArgumentTypeError(msg)

def dictstr(structure, ntabs):
    """Print parsed JSON dict in WHOIS-like textual format"""
    global raw_str
    for field in structure.keys():
        tabs=''
        for _ in range(ntabs):
            tabs += '\t'
        if isinstance(structure[field], list):
            raw_str += '%s%s: '%(tabs, field)
            comma=''
            for item in structure[field]:
                raw_str += '%s%s'%(comma, item)
                comma = ', '
            raw_str += '\n'
        elif isinstance(structure[field], dict):
            raw_str += '%s%s: \n'%(tabs, field)
            dictstr(structure[field], ntabs + 1)
        else:
            raw_str += '%s%s: %s\n'%(tabs, field, structure[field])
def is_empty_field(field):
    """True if field is empty string, empty list, empty dict or None"""
    return field is None or field == '' \
        or field == {} or field == []

def purge_empty_fields(structure):
    """Recusively eliminate empty string valued or None fields from a
    dictionary
    """
    for field in structure.copy().keys():
        if isinstance(structure[field], dict):
            structure[field] = purge_empty_fields(structure[field])
        if is_empty_field(structure[field]):
            structure.pop(field)
    return(structure)

#Handling arguments
ARGS_PARSER = ArgumentParser(
    description=\
    "Command-line utility to query domains in the WhoisXML API WHOIS service similarly to the whois command.",
    prog=MYNAME)
#Positional argument: the domain
ARGS_PARSER.add_argument("domainName", type=str, help="The domain to be queried. Domains with national characters can be Unicode or IDN.")
#Optional arguments
ARGS_PARSER.add_argument('--version',
                         help='Print version information and exit.',
                         action='version',
                         version=MYNAME + ' ver. ' + VERSION + '\n(c) WhoisXML API Inc.')
ARGS_PARSER.add_argument('--rcfile',
                         type=str,
                         help="Use this rc file. Will override all default ini locations.")
ARGS_PARSER.add_argument('--apikey',
                         type=str,
                         help="Directly specify the API key. Overrides any ini file.")
ARGS_PARSER.add_argument('--nocolor',
                         action='store_true',
                         help="Do not colorize output. Useful in scripts. Colors are not supported on Windows, so there it is default.")
ARGS_PARSER.add_argument('--text',
                         action='store_true',
                         help="Print a textual output instead of a JSON-style format.  Results in a behavior similar to the whois command.")
ARGS_PARSER.add_argument('--fullrawtext',
                         action='store_true',
                         help="Print all raw text field contents. The default is to suppress raw texts fully.")
ARGS_PARSER.add_argument('--strippedrawtext',
                         action='store_true',
                         help="Print the first 128 characters of raw text fields. The default is to suppress raw texts fully.")
ARGS_PARSER.add_argument('--keep-empty',
                         action='store_true',
                         help="Keep and display fields with empty and null values")
ARGS_PARSER.add_argument('--history',
                         action='store_true',
                         help="Get historic records from the history API. The following option imply this automatically.")
ARGS_PARSER.add_argument('--since-date',
                         help="(history) If present, search through activities discovered since the given date. Sometimes there is a latency between the actual added/renewal/expired date and the date when our system detected this change. We recommend using this field in your monitoring tools for filtering daily changes.",
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--created-date-from',
                         help='(history) If present, search through domains created after the given date.',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--created-date-to',
                         help='(history) If present, search through domains created before the given date.',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--updated-date-from',
                         help='(history) If present, search through domains updated after the given date.',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--updated-date-to',
                         help='(history) If present, search through domains updated before the given date.',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--expired-date-from',
                         help='(history) If present, search through domains expired after the given date. ',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
ARGS_PARSER.add_argument('--expired-date-to',
                         help='(history) If present, search through domains expired before the given date.',
                         metavar = 'YYYY-MM-DD',
                         type=valid_date)
#Parsing arguments
ARGS = ARGS_PARSER.parse_args()

#Adding rc file with priority if specified
if ARGS.rcfile is not None:
    RC_FILE_LOCS = [ARGS.rcfile] + RC_FILE_LOCS
#Setting API key from ini
apiKey = None
if ARGS.apikey is None:
    for rc_file_name in RC_FILE_LOCS:
        try:
            rc_file = open(rc_file_name)
            apiKey = rc_file.read().strip()
            rc_file.close()
            break
        except:
            pass
else:
    apiKey = ARGS.apikey

if apiKey is None:
    raise ValueError('No API key found. Check rc files or specify directly.')

#Fix the domain name IDN-wise

if IDN:
    domain_name = idna.encode(ARGS.domainName).decode('utf-8')
else:
    if not all(ord(char) < 128 for char in ARGS.domainName):
        sys.stderr.write('Please install the "idna" Python package to query non-ASCII unicode domain names.\nExiting.\n')
        exit(3)
    else:
        domain_name = ARGS.domainName

#Deciding which API to use
if ARGS.history or (ARGS.since_date is not None
                    or ARGS.created_date_from is not None
                    or ARGS.created_date_to is not None
                    or ARGS.updated_date_from is not None
                    or ARGS.updated_date_to is not None
                    or ARGS.expired_date_from is not None
                    or ARGS.expired_date_to is not None):
    API = 'https://whois-history-api.whoisxmlapi.com/api/v1?'\
                         + 'apiKey=' + apiKey \
                         + '&outputformat=JSON&mode=purchase'
    ARGS.history = True
else:
    API = 'https://www.whoisxmlapi.com/whoisserver/WhoisService?'\
          + 'apiKey=' + apiKey \
          + '&outputformat=JSON&ip=1'

URL = API + '&domainName=' + domain_name
#Processing optional API arguments for history API if given
if ARGS.history:
    if ARGS.since_date is not None:
        URL += '&sinceDate=%s'%ARGS.since_date
    if ARGS.created_date_from is not None:
        URL += '&createdDateFrom=%s'%ARGS.created_date_from
    if ARGS.created_date_to is not None:
        URL += '&createdDateTo=%s'%ARGS.created_date_to
    if ARGS.updated_date_from is not None:
        URL += '&updatedDateFrom=%s'%ARGS.updated_date_from
    if ARGS.updated_date_to is not None:
        URL += '&updatedDateTo=%s'%ARGS.updated_date_to
    if ARGS.expired_date_from is not None:
        URL += '&expiredDateFrom=%s'%ARGS.expired_date_from
    if ARGS.expired_date_to is not None:
        URL += '&expiredDateTo=%s'%ARGS.expired_date_to

try:
    result = requests.get(URL).json()
except Exception as e:
    sys.stderr.write('Error invoking API. The API key or the domain name is probably invalid.\n')
    sys.stderr.write('Error text: %s\n'%str(e))
    exit(1)

if ARGS.history:
    try:
        recordCount = result['recordsCount']
    except:
        recordCount = 0

    if recordCount == 0:
        print("No records found. The output of the API was:")
        print(json.dumps(result, indent=1, sort_keys=False))
        exit(2)
else:
    try:
        theRecord = result['WhoisRecord']
    except:
        print("No records found. The output of the API was:")
        print(json.dumps(result, indent=1, sort_keys=False))
        exit(2)
    result['records'] = [theRecord.copy()]

        
recordno = 0
for whoisRecord in result['records']:
    recordno += 1
    if not ARGS.keep_empty:
        whoisRecord = purge_empty_fields(whoisRecord)
    if ARGS.strippedrawtext:
        for textfield in ['rawText', 'strippedText', 'cleanText', 'header', 'footer']:
            try:
                whoisRecord[textfield] = \
                    whoisRecord[textfield][0:64]+"..."
            except:
                pass
        for subfield in whoisRecord.keys():
            for textfield in ['rawText', 'strippedText', 'cleanText', 'header', 'footer']:
                try:
                    whoisRecord[subfield][textfield] = \
                        whoisRecord[subfield][textfield][0:64]+"..."
                except:
                    pass
    elif not ARGS.fullrawtext:
        for textfield in ['rawText', 'strippedText', 'cleanText', 'header', 'footer']:
            try:
                whoisRecord.pop(textfield)
            except:
                pass
        for subfield in whoisRecord.keys():
            for textfield in ['rawText', 'strippedText', 'cleanText','header','footer']:
                try:
                    whoisRecord[subfield].pop(textfield)
                except:
                    pass

    json_str = json.dumps(whoisRecord, indent=1, sort_keys=False)
    if ARGS.history:
        print("Historic record no. %d of %d for %s:\n------------\n" % (
            recordno, recordCount, ARGS.domainName))
    if ARGS.text:
        raw_str=""
        dictstr(whoisRecord, 0)
        print(raw_str)
    elif ARGS.nocolor or sys.platform in {'win32', 'win64'}:
        print(json_str)
    else:
        print(highlight(json_str, JsonLexer(), TerminalFormatter()))

exit(0)

