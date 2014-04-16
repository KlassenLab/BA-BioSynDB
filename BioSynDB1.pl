#1/usr/bin/perl -w


use Bio::DB::GenBank;
#use Bio::SeqFeature;

#Use GenBank
$db_obj = Bio::DB::GenBank->new;

#Creates sequence obj from GenBank ac#
$ac_num = "M87280"; #AC number for Pantoea agglomeran 
$ac_num = "AAA64977"; #AC number for crtE
$seq_obj = $db_obj->get_Seq_by_acc($ac_num);
$type = $seq_obj->alphabet;

if ($type eq"dna") {

	#Finds the genes in the sequence and stores their feature objects in an array
	my @genes = grep { $_->primary_tag eq 'gene'} $seq_obj->all_SeqFeatures();

	#Create an array (@gene_names) containing the names of each gene in the sequence.
	for my $feat_obj (@genes) {	
		#print "primary tag: " . $feat_obj->primary_tag . "\n";
		for my $value ($feat_obj->get_tag_values("gene")) {
			push (@gene_names, $value); 
			#print "     value: " . $value . "\n";	
		}	
	}
	
	#Finds the CDS objects in the sequence and stores their feature objects in an array
	my @CDS_feats = grep { $_->primary_tag eq 'CDS'} $seq_obj->all_SeqFeatures();
	#Create an array containing a CDS feature object for each gene
	for my $name (@gene_names){	
		#print "test" . $name . "\n";	
		my @f = grep {  my @a = $_->has_tag('gene') ? $_->each_tag_value('gene') : (); 
	                                          grep { /$name/ } @a;  }  @CDS_feats;
		$f = @f[0]; #*WILL WE EVER HAVE MULTIPLE GENES IN SAME NAME AND SEQUENCE???????*
		$genes_CDS{$name} = $f;
		#print "***" . $name . "***" . ":  " . "\n";
		#print "primary tag: " . $f->primary_tag . "\n";
		for my $tag ($f->get_all_tags) {
			#print " tag:" . $tag . "\n";
			for my $value ($f->get_tag_values($tag)) {
				#print "     value: " . $value . "\n";
			}
		}
		#print "\n\n";
	}
	#Creates a Sequence object for each above gene's corresponding Protein 
	for my $name (@gene_names){
		$f = $genes_CDS{$name};
		for my $prot_id ($f->get_tag_values("protein_id")) {
			print $prot_id . "\n";	
			#RECURRSION, ENTERING EACH PROTEIN INTO THE SCRIPT
			push (@prot_ids, $prot_id);
			$prot_so = $db_obj->get_Seq_by_version($prot_id);		
		}
	}
	
}	
elsif ($type eq "protein") {
	print "Hello, World?\n";
}	
	
	


