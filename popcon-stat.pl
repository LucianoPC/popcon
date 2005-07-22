#! /usr/bin/perl -wT
#
# Require the debian package libchart-perl.

BEGIN {
@INC=(@INC, map { "./$_" } @INC);
}

$ENV{PATH}="/usr/bin:/bin";
$dirpng="../www/stat";
while (<>)
{
   my ($file);
   m/^(.*\/popcon-([0-9-]+)\.gz)$/ or next;
   $file=$1;
   $f=$2;
   push @date,$f;
   open FILE,"zcat $file|";
   while(<FILE>)
   {
     my @line=split(/ +/);
     if ($line[0] eq "Submissions:")
     {
       $subt{$f}=$line[1];
     }
     elsif ($line[0] eq "Architecture:")
     {
       $sub{$f}->{$line[1]}=$line[2];
       $arch{$line[1]}++;
     }
     elsif ($line[0] eq "Release:")
     {
       if (defined($line[2])) {
         $rel{$f}->{$line[1]}=$line[2];
       } else {
         $rel{$f}->{"unknown"}+=$line[1];
       }
     }
     elsif ($line[0] eq "Package:")
     {
       last;
     }
   }
   close FILE;
}

@days = sort grep { defined($sub{$_}->{'i386'}) } @date;
@data = (\@days);
@arch = sort keys %arch;
$maxv = -10;
for $arch (@arch)
{
  my @res=();
  for (@days)
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
$obj->set ('legend_labels' => [@arch]);
$obj->set ('f_y_tick' => \&ytick);
$obj->set ('brush_size' => 3);
$obj->set ('pt_size' => 7);
$obj->set ('max_val' => $maxv+1);
$obj->set ('y_ticks' => int $maxv +1);
$obj->set ('x_ticks' => 'vertical');
$obj->set ('skip_x_ticks' => 14);
$obj->png ("$dirpng/submission.png", \@data);

use Chart::Composite;
for $arch (@arch)
{
  my @data;
  my @res=();
  my @tot=();
  for (@days)
  {
    push @res,defined($sub{$_}->{$arch})?$sub{$_}->{$arch}:0;
    push @tot,defined($subt{$_})?$subt{$_}:0;
  }
  @data=(\@days,\@res,\@tot);
  @labels=($arch, 'all submissions');
  $obj=Chart::Composite->new (600,400);
  $obj->set ('title' => "Number of submissions for $arch");
  $obj->set ('legend_labels' => \@labels);
  $obj->set ('brush_size' => 3);
  $obj->set ('pt_size' => 7);
  $obj->set ('x_ticks' => 'vertical');
  $obj->set ('skip_x_ticks' => 14);
  $obj->set ('composite_info' => [ ['LinesPoints', [1]], ['LinesPoints', [2] ] ]); 
  $obj->png ("$dirpng/sub-$arch.png", \@data);
}

@days = sort grep { $_ ge "2004-05-14" } @date;
%release= map { map { $_ => 1 } keys %{$rel{$_}}  } @days;
@data = (\@days);
@release= sort keys %release;
for $release (@release)
{
  my @res=();
  for (@days)
  {
    my $data=defined($rel{$_}->{$release})?$rel{$_}->{$release}:0;
    push @res,$data;
  }
  push @data,\@res;
}
$obj=Chart::LinesPoints->new (600,400);
$obj->set ('title' => 'popularity-contest versions in use');
$obj->set ('legend_labels' => [@release]);
$obj->set ('brush_size' => 3);
$obj->set ('pt_size' => 7);
$obj->set ('x_ticks' => 'vertical');
$obj->set ('skip_x_ticks' => 14);
$obj->png ("$dirpng/release.png", \@data);
