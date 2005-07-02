#!/usr/bin/perl -wT

use strict;

my $email='test@popcon.debian.org';

$ENV{PATH}="";

print "Content-Type: text/plain\n\n";
if ($ENV{REQUEST_METHOD} ne "POST")
{
    print "Debian Popularity-Contest HTTP-POST submission URL\n";
    exit 0;
}
open POPCON, "|/usr/lib/sendmail -oi $email" or die "sendmail";
open GZIP, '/bin/gzip -dc|' or die "gzip";
close STDIN;
open STDIN, "<&GZIP";

print POPCON <<"EOF";
To: $email
Subject: popularity-contest submission

EOF
print POPCON while(<GZIP>);
close POPCON;

print "Thanks for your submission to Debian Popularity-Contest\n";
exit 0;
