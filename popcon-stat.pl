#! /usr/bin/perl -w
$png="submission.png";

for $f (@ARGV)
{
   open FILE,"zcat $f|";
   while(<FILE>)
   {
     my @line=split(/ +/);
     if ($line[0] eq "Submissions:")
     {
       $sub{$f}=$line[1];
     }
     elsif ($line[0] eq "Architecture:")
     {
       $sub{$f}->{$line[1]}=$line[2];
       $arch{$line[1]}++;
     }
     else 
     {
       last;
     }
   }
   close FILE;
}

@date=map {m/popcon-([0-9-]+)\.gz/ and $1} @ARGV;

@data=(\@date);
@arch=sort keys %arch;
$maxv=-10;
for $arch (@arch)
{
  my @res=();
  for (@ARGV)
  {
    my $data=defined($sub{$_}->{$arch})?log($sub{$_}->{$arch})/log(2)+1:0;
    push @res,$data;
    $maxv=$data if ($data > $maxv);
  }
  push @data,\@res;
}
@labels=(@arch);
sub ytick
{
  my ($x)=$_[0]-.5;
  $x < 0 and return 0;
  return int 2**$x;
}

use Chart::LinesPoints;
$obj=Chart::LinesPoints->new (600,400);
$obj->set ('title' => 'Number of submissions per architectures');
$obj->set ('legend_labels' => \@labels);
$obj->set ('f_y_tick' => \&ytick);
$obj->set ('brush_size' => 2);
$obj->set ('max_val' => $maxv+1);
$obj->set ('y_ticks' => int $maxv +1);
$obj->png ($png, \@data);
