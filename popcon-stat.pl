#! /usr/bin/perl -w
BEGIN {
@INC=(@INC, map { "./$_" } @INC);
}
$dirpng="../www/stat";

for $f (sort @ARGV)
{
   open FILE,"zcat $f|";
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
     elsif ($line[0] eq "Package:")
     {
       last;
     }
   }
   close FILE;
}

@days = sort grep { defined($sub{$_}->{'i386'}) } @ARGV;
@date = map {m/popcon-([0-9-]+)\.gz/ and $1} @days;
@data = (\@date);
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
$obj->set ('legend_labels' => \@labels);
$obj->set ('f_y_tick' => \&ytick);
$obj->set ('brush_size' => 2);
$obj->set ('pt_size' => 9);
$obj->set ('max_val' => $maxv+1);
$obj->set ('y_ticks' => int $maxv +1);
$obj->set ('x_ticks' => 'vertical');
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
  @data=(\@date,\@res,\@tot);
  @labels=($arch, 'all submisions');
  $obj=Chart::Composite->new (600,400);
  $obj->set ('title' => "Number of submissions for $arch");
  $obj->set ('legend_labels' => \@labels);
  $obj->set ('brush_size' => 2);
  $obj->set ('pt_size' => 9);
  $obj->set ('x_ticks' => 'vertical');
  $obj->set ('composite_info' => [ ['LinesPoints', [1]], ['LinesPoints', [2] ] ]); 
  $obj->png ("$dirpng/sub-$arch.png", \@data);
}

