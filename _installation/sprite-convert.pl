#!/usr/bin/perl

use strict;
use GD;

my ($size,$dir,$outpng,$outcss) = @ARGV;

my $line = 100; # Это кол-во иконок на одну строку, т.е. выходной файл будет шириной $size*$line пикселей

# Если пропустили параметр, выдаем подсказку
unless ((defined $size) and (defined $dir) and (defined $outpng) and (defined $outcss)){
# Собственно,
#     size - размер исходной иконки
#     dir - каталог с иконками
#     outpng - выходной png файл
#     outcss - выходной css файл
die <<"--info--";
$0 <size> <dir> <outpng> <outcss>
--info--
}

# Поехали!
opendir(my $dhandle,$dir);
my @pngs = grep !/^\.\.?$/,readdir($dhandle);
closedir($dhandle);

my $width = $line*$size;
my $height = $size*(int($#pngs/$line)+1);

my $im = new GD::Image($width,$height,1); # Вот эта единица, это truecolor включаем
# Альфа-канал из иконок будет сохранен
$im->alphaBlending(0);
$im->saveAlpha(1);

my $i=0;
my $j=0;

open(my $css,">",$outcss);
# Поскольку я использую bootstrap from twitter в этом проекте, тут у меня bootstrap-like стили для иконок
print $css <<"--css--";
[class^="mcm-i-"]
    {
    display:inline-block;
    width:${size}px;
    height:${size}px;
    vertical-align:text-top;
    background-image:url(/images/mcm-icons.png);
    background-position:${size}px ${size}px;
    background-repeat:no-repeat;*margin-right:.3em;
    }
[class^="mcm-i-"]:last-child{*margin-left:0;}
--css--
for (sort @pngs) {
my $png = GD::Image->newFromPng($dir.'/'.$_,1);
$im->copy($png,$i*$size,$j*$size,0,0,$size,$size);
my ($name,$ext) = split /\./,$_;
printf $css " \
    .mcm-i-$name {background-position:%dpx %dpx;}",-$size*$i,-$size*$j;
$i++;
if($i>=$line){$j++;$i=0;}
}
close($outcss);

open(my $png,">",$outpng);
binmode($png);
print $png $im->png(9); # Пожмем как сможем вывод
close($png);