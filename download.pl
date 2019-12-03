if (!-e "prokaryotes.txt") {
	"Downloading prokaryotes.txt...\n";
	`wget -O prokaryotes.txt ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt `
}

$sra = "fasterq-dump.2.9.6";
$query = $ARGV[0];
@list = split (/\n/, `grep "$query" prokaryotes.txt`);
if (scalar @list == 0) {
	@parts = split (/ /,$query);
	print STDERR join "|",@parts,"\n";
	@list = split (/\n/, `grep $parts[0] prokaryotes.txt`) if (scalar @parts == 1);
	@list = split (/\n/, `grep "$parts[0] prokaryotes.txt | grep $parts[1]`) if (scalar @parts == 2);
	@list = split (/\n/, `grep "$parts[0]" prokaryotes.txt | grep $parts[1] | grep $parts[2]`) if (scalar @parts == 3);
	if (scalar @list == 0) {
		print STDERR "No match found in NCBI prokaryotes.txt";
		exit;
	}
}

foreach $org (@list) {
	chomp $org;
	@tmp = split (/\t/,$org);
	$name = $tmp[0];
	$out = $tmp[0];
	$out =~ s/ /_/g;
	print STDERR "QUERY: $name\n";
	print STDERR "   STATUS: $tmp[15]\n";
	$ftp = $tmp[20];
	$file = $ftp;
	$file =~ s/.+\///;
	$gff = $ftp."/".$file.".genomic.gff.gz";
	print STDERR "   GFF: $gff\n";
	$fna = $ftp."/".$file.".genomic.fna.gz"; 
	print STDERR "   FNA: $fna\n";
	$acc = $tmp[17];
	print STDERR "   SAMPLE: $acc\n";
	$sraid = `wget -q -O- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=biosample&term=$acc"`;
	$sraid =~ /<Id>(\d+)<\/Id>/;
	$sraid = $1;
	print STDERR "   SRA: $sraid\n";
	$runid = `wget -q -O- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&id=25444"`;
	$runid =~ /(SRR\d+)/;
	$runid = $1;
	print STDERR "   RUN: $runid\n";
	$ftp = "ftp://ftp.sra.ebi.ac.uk/vol1/fastq";
	$runid =~ /^(.{6})/;
	$part1 = $1;
	$runid =~ /(\d)$/;
	$part2 = "00".$1;
	#first check for monoreads file
	$link1 = "$ftp/$part1/$part2/$runid/$runid".".fastq.gz";
	print STDERR "   URL: $link1\n";
	$check = `wget -q -O/dev/null $link1 && echo 1 || echo 0`;
	if ($check == 1) {
		print STDERR "   TYPE: single\n";
		print STDERR "   Downloading read file from $link1\n";
	} 
	else {
	#then check for paired reads files
		$link1 = "$ftp/$part1/$part2/$runid/$runid".".1.fastq.gz";
		$check = `wget -q -O/dev/null $link1 && echo 1 || echo 0`;
		if ($check == 1) {
			print STDERR "   TYPE: paired\n";
			print STDERR "   Downloading read pair 1 from $link1\n";
			`wget -O $out.1.fastq.gz $link1`;
			$link2 = "$ftp/$part1/$part2/$runid/$runid".".2.fastq.gz";
			print STDERR "   Downloading read pair 2 from $link2\n";
			`wget -O $out.2.fastq.gz $link2`;
		} else {
			print STDERR "Read file/s not found.\n";
		}
	}
	
#	ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR826/009/SRR8263259/SRR8263259_1.fastq.gz
#	print STDERR "   OUT: $out.fastq, downloading...\n";
#	`$sra -O $out.fastq $runid`;
}
