#!/bin/bash
#Some simple test cases for the bestwhois command-line tool
#Part of the bestwhois utility, (c) WhoisXML API, Inc.
ERRORCOUNT=0

#Basic tests
echo "Test No. 1"
./bestwhois domainwhoisdatabase.com --text --strippedrawtext
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 2"
./bestwhois --history domainwhoisdatabase.com --expired-date-to 2017-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
#Empty result set, history
echo "Test No. 3"
./bestwhois domainwhoisdatabase.com --expired-date-from 2040-01-01
RETCODE=$?
if [[ $RETCODE != 2 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
#bad API key
echo "Test No. 4"
./bestwhois google.com --text --history --fullrawtext --apikey foo
RETCODE=$?
#Invalid domain name
echo "Test No. 5"
./bestwhois foobar
RETCODE=$?
if [[ $RETCODE != 2 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 6"
./bestwhois foobar --history
RETCODE=$?
if [[ $RETCODE != 1 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 7"
./bestwhois domainwhoisdatabase.com --created-date-from 2000-01-01 --created-date-to 2016-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
# Combinations of date limitations
echo "Test No. 8"
./bestwhois domainwhoisdatabase.com --updated-date-from 2000-01-01 --updated-date-to 2016-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 9"
./bestwhois domainwhoisdatabase.com --updated-date-from 2000-01-01 --created-date-to 2016-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 10"
./bestwhois domainwhoisdatabase.com --created-date-from 2000-01-01 --expired-date-to 2014-01-01
RETCODE=$?
if [[ $RETCODE != 2 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 11"
./bestwhois domainwhoisdatabase.com --created-date-from 2000-01-01 --expired-date-to 2020-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 12"
./bestwhois domainwhoisdatabase.com --expired-date-from 2000-01-01 --expired-date-to 2018-01-01
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
echo "Test No. 13"
./bestwhois москва.рф
RETCODE=$?
if [[ $RETCODE != 0 ]];then echo "ERROR";let ERRORCOUNT++;else echo "OK";fi
#Reporting error count
echo "ERROR COUNT: $ERRORCOUNT"
