#!/usr/bin/perl
#the gff file
open(IN,"zcat $ARGV[0]|") or die "no"; #annotation gff from refseq
while($line = <IN>) {
	next if ($line =~ /^#/);
	@a = split (/[\t;]/,$line);
	$name = '';
	$prod = '';
#	print $a[2],"\n";
	next if ($a[2] ne 'CDS');
	$line =~ /Name=(.+?);/;
	$name = $1;
	$line =~ /product=(.+?);/;
	$prod = $1;
	$chr{$name} = $a[0];
	$st{$name} = $a[3];
	$en{$name} = $a[4];
	$product{$name} = $prod;
}
close IN;
print STDERR scalar keys %product, " proteins loaded...\n";
$out = $ARGV[1];
$out =~ s/\.peaks/.prots/;
open(IN,$ARGV[1]); #output of peakFind
open(OUT,">$out"); #output of peakFind
$cnt = 0;
while($line = <IN>) {
	next if ($line =~ /^#/);
	$cnt++;
	chomp $line;
	($chr,$st,$en,$cov,$len) = split (/\t/,$line); 
	print STDERR "Scanning region $chr - $st - $en\n";
	foreach $prot (keys %product) {
		next if ($chr ne $chr{$prot});
		$mode = "int" if ($st{$prot}>=$st && $en{$prot}<=$en);
		$mode = "ext" if ($st{$prot}<= $st && $en{$prot}>=$en);
#		print STDERR "--\n -> protein $chr,$st{$prot},$en{$prot}\n -> region  $chr,$st,$en,$cov ---> match $mode     -> $prot\t$product{$prot}\n--\n" if ($st{$prot}>=$st && $en{$prot}<=$en);
#		print STDERR "--\n -> protein $chr,$st{$prot},$en{$prot}\n -> region  $chr,$st,$en,$cov ---> match $mode -> $prot\t$product{$prot}\n--\n" if ($st{$prot}<= $st && $en{$prot}>=$en);
#		<STDIN> if ($st{$prot}>=$st && $en{$prot}<=$en || $st{$prot}<= $st && $en{$prot}>=$en);
		print OUT "$prot\t$mode\t$chr\t$st{$prot}\t$en{$prot}\t$st\t$en\t$product{$prot}\n" if ($st{$prot}>=$st && $en{$prot}<=$en || $st{$prot}<= $st && $en{$prot}>=$en);	
	}
}
close IN;
close OUT;
$out = $ARGV[1].".prot";

#open(OUT,">$out");
#foreach $i (1..$cnt) {
#	print OUT scalar @{$in{$i}},"\t",join "|",@{$in{$i}},"\n";
#}
