#! /usr/bin/perl -wT

$results="../popcon-mail/results";
$popcon="../www";

sub htmlheader
{
  print HTML <<"EOH";
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
  <html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <title> Debian Popularity Contest </title>
        <link rev="made" href="mailto:ballombe\@debian.org">
        </head>
        <body text="#000000" bgcolor="#FFFFFF" link="#0000FF" vlink="#800080" alink="#FF0000">
        <div align="center">
        <a href="http://www.debian.org/">
        <img src="http://www.debian.org/logos/openlogo-nd-50.png" border="0" hspace="0" vspace="0" alt="">
        </a>
        <a href="http://www.debian.org/">
        <img src="http://www.debian.org/Pics/debian.jpg" border="0" hspace="0" vspace="0" alt="Debian Project">
        </a>
        </div>
        <br>
        <table bgcolor="#DF0451" border="0" width="100%" cellpadding="0" cellspacing="0" summary="">
        <tr>
        <td valign="top">
        <img src="http://www.debian.org/Pics/red-upperleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
        </td>
        <td rowspan="2" align="center">
        <font color="#FFFF00"><big><big>Debian Popularity Contest</big></big></font>
        </td>
        <td valign="top">
        <img src="http://www.debian.org/Pics/red-upperright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
        </td>
        </tr>
        <tr>
        <td valign="bottom">
        <img src="http://www.debian.org/Pics/red-lowerleft.png" align="left" border="0" hspace="0" vspace="0" alt="" width="16" height="16">
        </td>
        <td valign="bottom">
        <img src="http://www.debian.org/Pics/red-lowerright.png" align="right" border="0" hspace="0" vspace="0" alt="" width="15" height="16">
        </td>
        </tr>
        </table>
EOH
}

sub popconintro
{
  print HTML <<"EOH";
  <p> <em> The popularity contest project is an attempt to map the usage of
  Debian packages.  This site publishes the statistics gathered from report send by users of the <a href="http://packages.debian.org/popularity-contest">popularity-contest</a> package. This package send every week the list of packages installed and the access time of relevant files to the server via email. Every day the server anonymize the result and publishes this survey.
  For more information, read the <a href="README">README</a> and the 
  <a href="FAQ">FAQ</a>.
  </em> <p>
EOH
}

sub htmlfooter
{
  my $date=gmtime();
  print HTML <<EOF;
<pre>
inst     : number of people who installed this package;
vote     : number of people who use this package regularly;
old      : number of people who installed, but don't use this package regularly;
recent   : number of people who upgraded this package recently;
no-files : number of people whose entry didn't contain enough information (atime
and ctime were 0).
</pre>
<p>
Number of submissions considered: $numsub
</p><p>
To participate in this survey, install the <a href="http://packages.debian.org/popularity-contest">popularity-contest</a> package.
</p>
EOF
  print HTML <<EOH
<p>
<HR>
<small>
Made by <a href="mailto:ballombe\@debian.org"> Bill Allombert </a>. Last generated on $date UTC. <br>
<a href="http://popcon.alioth.debian.org" > Popularity-contest project <a> by Avery Pennarun, Bill Allombert and Petter Reinholdtsen.
<BR>
Copyright (C) 2004 <A HREF="http://www.spi-inc.org/">SPI</A>;
See <A HREF="http://www.debian.org/license">license terms</A>.
</small>
</body>
</html>
EOH
}

sub make_sec
{
  my $sec="$popcon/$_[0]";
  -d $sec || system("mkdir","-p","$sec");
}

sub print_by
{
   my ($dir,$f)=@_;
   print HTML ("<a href=\"$dir/by_$f\">$f</a> [<a href=\"$dir/by_$f.gz\">gz</a>] ");
}

sub make_by
{
  my ($sec,$order,$pkg,@list) = @_;
  my %sum;
  @list = sort {$pkg->{$b}->{$order}<=> $pkg->{$a}->{$order} || $a cmp $b } @list;
  $winner{"$sec/$order"}=$list[0];
  open DAT , "| tee $popcon/$sec/by_$order | gzip -c > $popcon/$sec/by_$order.gz";
  if ($sec eq "maint")
  {
    print DAT <<"EOF";
#Format
#   
#<name> is the developer name;
#
#The fields below are the sum for all the packages maintained by that
#developer:
#
#<inst> is the number of people who installed this package;
#<vote> is the number of people who use this package regularly;
#<old> is the number of people who installed, but don't use this package
#      regularly;
#<recent> is the number of people who upgraded this package recently;
#<no-files> is the number of people whose entry didn't contain enough
#           information (atime and ctime were 0).
#rank name                            inst  vote   old recent no-files
EOF
  }
  else 
  {
    print DAT <<"EOF";
#Format
#   
#<name> is the package name;
#<inst> is the number of people who installed this package;
#<vote> is the number of people who use this package regularly;
#<old> is the number of people who installed, but don't use this package
#        regularly;
#<recent> is the number of people who upgraded this package recently;
#<no-files> is the number of people whose entry didn't contain enough
#        information (atime and ctime were 0).
#rank name                            inst  vote   old recent no-files (maintainer)
EOF
  }
  $format="%-5d %-30s".(" %5d"x($#fields+1))." %-32s\n";
  my $rank=0;
  for $p (@list)
  {
    $rank++;
    my $m=($sec eq "maint"?"":"($maint{$p})");
    printf  DAT $format, $rank, $p, (map {$pkg->{$p}->{$_}} @fields), $m;
    $sum{$_}+=$pkg->{$p}->{$_} for (@fields);
  }
  print  DAT '-'x66,"\n";
  printf DAT $format, $rank, "Total", map {defined($sum{$_})?$sum{$_}:0} @fields;
  close DAT;
}

sub print_pkg
{
  my ($pkg)=@_;
  return unless (defined($pkg));
  my $size=length $pkg;
  my $pkgt=substr($pkg,0,20);
  print HTML "<a href=\"http://packages.debian.org/$pkg\">$pkgt</a> ",
  ' 'x(20-$size);
}


%pkg=();
%section=();
%maint=();
%winner=();
%maintpkg=();
@fields=("inst","vote","old","recent","no-files");

for $file ("slink","slink-nonUS","potato","potato-nonUS","woody","woody-nonUS")
{
  open AVAIL, "< $file.sections" or die "Cannot open $file.sections";
  while(<AVAIL>)
  {
	  my ($p,$sec)=split(' ');
	  defined($sec) or last;
	  chomp $sec;
	  $sec =~ m{^(non-US|contrib|non-free)/} or $sec="main/$sec";
	  $section{$p}=$sec;
	  $maint{$p}="Not in sid";
  }
  close AVAIL;
}


for $file (glob("/org/ftp.root/debian/dists/testing/*/binary-*/Packages"),glob("/org/ftp.root/debian/dists/sid/*/binary-*/Packages"))
{
  open AVAIL, "$file";
  while(<AVAIL>)
  {
/Package: (.+)/  and do {$p=$1;$maint{$p}="bug";next;};
/Maintainer: ([^()]+) (\(.+\) )*<.+>/ and do { $maint{$p}=join(' ',map{ucfirst($_)} split(' ',lc $1));next;};
/Section: (.+)/ or next;
          $sec=$1;
          $sec =~ m{^(non-US|contrib|non-free)/} or $sec="main/$sec";
          $section{$p}=$sec;
  }
  close AVAIL;
}
$ENV{PATH}="/bin:/usr/bin";

#Format
#<name> <vote> <old> <recent> <no-files>
#   
#<name> is the package name;
#<vote> is the number of people who use this package regularly;
#<old> is the number of people who installed, but don't use this package
#        regularly;
#<recent> is the number of people who upgraded this package recently;
#<no-files> is the number of people whose entry didn't contain enough
#        information (atime and ctime were 0).

open PKG, "$results";
while(<PKG>)
{
  my ($type,@values)=split(" ");
  if ($type eq "Package:")
  {
          my @votes=@values;
	  $name = shift @votes;
	  unshift @votes,$votes[0]+$votes[1]+$votes[2]+$votes[3];
	  $section{$name}='unknown' unless (defined($section{$name}));
	  $maint{$name}='Not in sid' unless (defined($maint{$name}));
	  for(my $i=0;$i<=$#fields;$i++)
	  {
		  my ($f,$v)=($fields[$i],$votes[$i]);
		  $pkg{$name}->{$f}=$v;
		  $maintpkg{$maint{$name}}->{$f}+=$v;
	  }
  }
  elsif ($type eq "Architecture:")
  {
    my ($a,$nb)=@values;
    $arch{$a}=$nb;
  }
  elsif ($type eq "Submissions:")
  {
    ($numsub)=@values;
  }
}

@pkgs=sort keys %pkg;
%sections = map {$section{$_} => 1} keys %section;
@sections = sort keys %sections;
@maints= sort keys %maintpkg;

for $sec (@sections)
{
  my @list = grep {$section{$_} eq $sec} @pkgs;
  make_sec $sec;
  make_by ($sec, $_, \%pkg, @list) for (@fields);
}

@dists=("main","contrib","non-free","non-US");
#There is a hack: '.' is both the current directory and
#the catchall regexp.

for $sec (".",@dists)
{
  my @list = grep {$section{$_} =~ /^$sec/ } @pkgs;
  make_by ($sec, $_, \%pkg, @list) for (@fields);
}
make_sec "maint";
make_by ("maint", $_, \%maintpkg, @maints) for (@fields);
for $sec (@dists)
{
  open HTML , "> $popcon/$sec/index.html";
  opendir SEC,"$popcon/$sec";
  &htmlheader;
  printf HTML ("<p>Statistics for the section %-16s sorted by fields: ",$sec);
  print_by (".",$_) for (@fields);
  print HTML ("\n </p> \n");
  printf HTML ("<p> <a href=\"first.html\"> First packages in subsections for each fields </a>\n");
  printf HTML ("<p>Statistics for subsections sorted by fields\n <pre>\n");
  for $dir (sort readdir SEC)
  {
    -d "$popcon/$sec/$dir" or next;
    $dir !~ /^\./ or next;
    printf HTML ("%-16s : ",$dir);
    print_by ($dir,$_) for (@fields);
    print HTML ("\n");
  }
  print HTML ("\n </pre>\n");
  &htmlfooter;
  closedir SEC;
  close HTML;
}
for $sec (@dists)
{
  open HTML , "> $popcon/$sec/first.html";
  opendir SEC,"$popcon/$sec";
  &htmlheader;
  printf HTML ("<p>First package in section %-16s for fields: ",$sec);
  for $f (@fields)
  {
	  print_pkg $winner{"$sec/$f"};
  }
  print HTML ("\n </p> \n");
  printf HTML ("<p> <a href=\"index.html\"> Statistics by subsections sorted by fields </a>\n");
  printf HTML ("<p>First package in subsections for fields\n <pre>\n");
  printf HTML ("%-16s : ","subsection");
  for $f (@fields)
  {
	  printf HTML ("%-20s ",$f);
  }
  print HTML ("\n","_"x120,"\n");
  for $dir (sort readdir SEC)
  {
	  -d "$popcon/$sec/$dir" or next;
	  $dir !~ /^\./ or next;
	  printf HTML ("%-16s : ",$dir);
	  for $f (@fields)
	  {
		  print_pkg $winner{"$sec/$dir/$f"};
	  }
	  print HTML ("\n");
  }
  print HTML ("\n </pre>\n");
  &htmlfooter;
  closedir SEC;
  close HTML;
}
{
	open HTML , "> $popcon/index.html";
	&htmlheader;
	&popconintro;
	printf HTML ("<p>Statistics for the whole archive sorted by fields: <pre>",$sec);
	print_by (".",$_) for (@fields);
	print HTML ("</pre>\n </p> \n");
	printf HTML ("<p>Statistics by maintainers sorted by fields: <pre>",$sec);
	print_by ("maint",$_) for (@fields);
	print HTML ("</pre>\n </p> \n");
	printf HTML ("<p>Statistics for sections sorted by fields\n <pre>\n");
  	for $dir ("main","contrib","non-free","non-US","unknown")
	{
		-d "$popcon/$dir" or next;
		$dir !~ /^\./ or next;
		if ($dir eq "unknown")
		{
			printf HTML ("%-16s : ",$dir);
		}
		else
		{
			printf HTML ("<a href=\"$dir/index.html\">%-16s</a> : ",$dir);
		}
		print_by ($dir,$_) for (@fields);
		print HTML ("\n");
	}
	print HTML  <<'EOF';
</pre>
<table border="0" cellpadding="5" cellspacing="0" width="100%">
<tr>
<td>
Statistics for architectures
<pre>
EOF
        for $f (grep { $_ ne 'unknown' } sort keys %arch)
        {
		my ($port)=split('-',$f);
		$port="$port/";
		$port="freebsd/gnu-libc-based" if ($port eq "kfreebsd/");
                printf HTML "<a href=\"http://www.debian.org/ports/$port\">%-16s</a> : %-10s <a href=\"/stat/sub-$f.png\">graph</a>\n",$f,$arch{$f};
        }
        printf HTML "%-16s : %-10s <a href=\"/stat/sub-unknown.png\">graph</a>\n","unknown",$arch{"unknown"};
	print HTML  <<'EOF';
</pre></td>
<td>
 <img alt="Graph of number of submissions per architectures"
 src="/stat/submission.png">
</td></tr>
</table>
<p>
EOF

	print HTML "<a href=\"all-popcon-results.txt.gz\">Raw popularity-contest results</a>\n";
	&htmlfooter;
	close HTML;
}

