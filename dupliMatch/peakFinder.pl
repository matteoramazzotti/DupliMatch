#/usr/bin/perl
$ratio = $ARGV[1];
$minlen = $ARGV[2];

open(IN,"$ARGV[0]");
while ($line = <IN>) {
	chomp $line;
	($f,$p,$c) = split (/\t/,$line);
	push(@{$cov{$f}},$c);
}
close IN;

foreach $k (keys %cov) {
	$m = 0;
	foreach $v (@{$cov{$k}}) {
		$m += $v;
	}
	$m{$k} = $m / scalar @{$cov{$k}};
#	print STDERR "$k -> $m{$k}\n";
}

foreach $k (keys %cov) {
	$cnt = 0;
	$status = "out";
	foreach $v (@{$cov{$k}}) {
		$cnt++;
		if($v > $ratio*$m{$k} && $status ne 'in') {
			push(@{$starts{$k}},$cnt);
			$start = $cnt;
			$status = "in";
		}
		if($v < $ratio*$m{$k} && $status eq "in") {
			$peaks++;
			push(@{$stops{$k}},$cnt);
			$status = "out";
		}
	}
}
$out = $ARGV[0];
$out =~ s/\.cov/.peaks/;
open(OUT,">$out");
print OUT "#START\tSTOP\tMEAN\tLENGTH\n";
foreach $k (keys %cov) {
	print OUT "#$k GRANDMEAN=$m{$k}\n";
	@starts = @{$starts{$k}};
	@stops = @{$stops{$k}};
	foreach $i (0..$#starts) {
		$length = ($stops[$i]-$starts[$i]+1);
		next if ($length < $minlen);
		$ml = 0;
		$cnt = 0;
		foreach $p ($starts[$i]..$stops[$i]) {
	#		print STDERR $p,"-";
			$ml += $cov{$k}[$p];
			$cnt++;
		}
		print OUT $k,"\t",$starts[$i],"\t",$stops[$i],"\t",$ml/$cnt,"\t",$length,"\n";
		`Rscript peakplot.R 1018_SAUR.cov NZ_JWGC01000026.1 29500 29650`
	}
}
close OUT;

