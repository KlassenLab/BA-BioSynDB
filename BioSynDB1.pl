#1/usr/bin/perl -w


use Bio::DB::GenBank;
#use Bio::SeqFeature;

#Use GenBank
$db_obj = Bio::DB::GenBank->new;

#Creates sequence obj from GenBank ac#
$seq_obj = $db_obj->get_Seq_by_acc(M87280);

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
	my @f = grep {  my @a = $_->has_tag('gene') ? $_->each_tag_value('gene') : (); 
                                          grep { /$name/ } @a;  }  @CDS_feats;
	$f = @f[0]; #*WILL WE EVER HAVE MULTIPLE GENES IN SAME NAME AND SEQUENCE???????*
	$genes_CDS{$name} = $f;
	print "***" . $name . "***" . ":  " . "\n";
	print "primary tag: " . $f->primary_tag . "\n";
	for my $tag ($f->get_all_tags) {
		print " tag:" . $tag . "\n";
		for my $value ($f->get_tag_values($tag)) {
			print "     value: " . $value . "\n";
		}
	}
	print "\n\n";
}
for my $name (@gene_names){
	#print $name. ":  " . $genes_CDS{$name} . "\n";
}







=begin comment
for comment
my @f_with_crtE = grep { 		#get all features filtering for those with crtE tag
	my @a = $_->has_tag('gene') ? $_->each_tag_value('gene') : (); grep {/crtE/ } @a; 
} $seq_obj->all_SeqFeatures();

print @f_with_crtE;
foreach $feat (@f_with_crtE) {
	print $function . "\n";
}
=end comment
%seq = (#Hash table for seq info
	"locName" => $seq_obj->display_name,	#locus name
	"id" => $seq_obj->display_id, 		#seq id
	"ac" => $seq_obj->accession_number, 	#accession number
	"desc" => $seq_obj->desc,		#description
);


#@seq_feat = $seq_obj->get_SeqFeatures;

#print  $seq_obj->display_id. "\n";
