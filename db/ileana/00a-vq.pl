#! /usr/bin/perl 

use strict;
use DBI;
use GraphViz;


my $dbfile = "DB/dunce.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
END { $dbh->disconnect if ($dbh) }

my $outputdir = "GRAPHS";

my @formats = qw/dot circo neato/;  #  circo dot neato twopi fdp

my @persons	= ("Colley Cibber", "Edmund Curll", "Eliza Haywood", "Giles Jacob", "John Dennis", "John Henley");
#my @persons	= ("Eliza Haywood");
my @relations = ("Akin to", "Attacked", "Defended", "Dissimilar");
my %atts = ();
$atts{'node'}{$relations[0]} = {'style' => 'bold',		'color' => 'green'};
$atts{'node'}{$relations[1]} = {'style' => 'bold',		'color' => 'red'};
$atts{'node'}{$relations[2]} = {'style' => 'dotted',	'color' => 'green'};
$atts{'node'}{$relations[3]} = {'style' => 'dotted',	'color' => 'red'};

for my $format (@formats) {
	#&make_dot(\@relations, \@persons, \%atts, $outputdir, $format);
	&make_dot(['ALL'], \@persons, \%atts, $outputdir, $format);
	&make_dot(\@relations, ['ALL'], \%atts, $outputdir, $format);
	&make_dot(['ALL'], ['ALL'], \%atts, $outputdir, $format);
}

exit;

sub make_dot {
	my @relations	= @{shift()};
	my @persons		= @{shift()};
	my %atts		= %{shift()};
	my $outputdir	= shift;
	my $format		= shift();

	for my $r (@relations) {

		for my $p (@persons) {

			my $gname = "G_${p}_${r}";
			$gname =~ s/\s+//g;
			print "DOING $format $gname\n";

			my $g = GraphViz->new(
				layout		=> $format, 
				ratio		=> 'compress',
				concentrate  => 1,
				rankdir      => 1, 
				no_overlap	   => 1,
				name				   => $gname,
				node				   => {shape => 'rectangle', fontsize => 24},
			);
			
			my $r_search = $r; my $p_search = $p;
			$r_search =~ s/ALL/%/; $p_search =~ s/ALL/%/;

			my $sql = "SELECT DISTINCT person, referent, relation FROM raw WHERE relation LIKE '$r_search' AND (person LIKE '$p_search' OR referent LIKE '$p_search') ";
			my $rs = $dbh->selectall_arrayref($sql);
			for my $r (@$rs) {
				my $px 	= $r->[0];
				my $rx 	= $r->[1];
				my $rel = $r->[2];
				$g->add_edge($px => $rx, style => $atts{node}{$rel}{style}, color => $atts{node}{$rel}{color});
			}

			my $sql = "SELECT DISTINCT person, referent, relation FROM curll2a WHERE relation LIKE '$r_search' AND (person LIKE '$p_search' OR referent LIKE '$p_search') ";
			my $rs = $dbh->selectall_arrayref($sql);
			for my $r (@$rs) {
				my $px 	= $r->[0];
				my $rx 	= $r->[1];
				my $rel = $r->[2];
				$g->add_edge($px => $rx, style => $atts{node}{$rel}{style}, color => $atts{node}{$rel}{color});
			}

			#$g->as_png("$outputdir/$gname-$format.png");
			#$g->as_jpeg("$outputdir/$gname-$format.jpeg");
			$g->as_svg("$outputdir/$gname-$format.svg");
			$g->as_canon("$outputdir/$gname.$format");
			                  
		}
	}
}