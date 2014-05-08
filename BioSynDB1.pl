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
	my $p_annos = $seq_obj->annotation;
	for my $key ( $p_annos->get_all_annotation_keys ) {
		my @annotations = $p_annos->get_Annotations($key);
		for my $value ( @annotations ) {
			#print "tagname : ", $value->tagname, "\n";
      			# $value is an Bio::Annotation, and also has an "as_text" method
      			#print "  annotation value: ", $value->display_text, "\n";
  		}
	}
	
	
	@p_fs = $seq_obj->get_SeqFeatures();
	$num_feats = 0; 
	for my $f (@p_fs){
		$spliced_seq = $f->spliced_seq()->seq;
		#The AA sequence for the current feat. object
		$f_loc = $f->location;
		#The location object of the current feature
		if ( $f_loc->isa('Bio::Location::SplitLocationI')
               				&& $f->primary_tag eq 'CDS' )  {
    			for my $location( $f->location->sub_Location ) {
				$seq_cord = $seq_cord.$f_loc->start. ".." . $f_loc->end . ",  ";
     			}
			print "\n";
			#creates a string "$seq_cord" with the start and end location of the current feature
		}
		else {
			$seq_cord = $f_loc->start . ".." . $f_loc->end;
			
		}
		print "primary tag: " . $f->primary_tag. "   " . $seq_cord . "\n";
		for my $tag ($f->get_all_tags){
			print "   tag: " . $tag . "\n";
			for my $value ($f->get_tag_values($tag)) {
				print "\t value: " . $value . "\n";
			}
		} 
		print "\t sequence: " . $spliced_seq . "\n\n";
		$num_feats++;
		
	}
	@references = $p_annos->get_Annotations("reference");
	#Stores all references in an array
	$n = 1;
	print "References: \n";
	for my $reference (@references){
		print "{".$n."}\n\t Title: " . $reference->title . "\n\t Authors: " . 				$reference->authors . "\n\t Pubmed id: " . $reference->pubmed . "\n";
		#Prints the current count number and the title, author, and pubmed id for the associated reference		
		$n++;
	} 	
	
}
	
	


