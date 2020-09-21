use 5.010;
use List::MoreUtils qw/uniq/;

my $file = "vmware_rep.csv";
open my $fh, "<", $file
	or die "can not open $file: $!";
my @host_1, @host_2, @guest_1, @guest_2, @con_1, @con_2;

foreach (<$fh>) {
	chomp;
	my @line = split /,/, $_;
	my $gueststr = "\"$line[0]\" \[ label=\"Name: $line[0]\\l|. . . IP: $line[2]\\l|. . . DNS: $line[11]\\l|. . . OS: $line[5]\\l|. . . CPU: $line[7], Mem: $line[6]\\l|. . . Space: $line[3], Cluster: $line[10]\\l\" \];";
	$line[1] =~ s/.foo.local//;
	my $hoststr = "\"$line[1]\" \[ label=\"Name: $line[1]\\l\\n. . . $line[12]\\l\\n. . . $line[13]\\l\" \];";
	my $connectstr = "\"$line[1]\" -> \"$line[0]\";";
	if ($line[1] =~ /p$/) {
		push(@host_2, $hoststr);
		push(@con_2, $connectstr);
		push(@guest_2, $gueststr);
	} else {
		push(@host_1, $hoststr);
		push(@con_1, $connectstr);
		push(@guest_1, $gueststr);
	};
};

my @uguest_1 = uniq sort @guest_1;
my @uguest_2 = uniq sort @guest_2;

my @uhost_1 = uniq sort @host_1;
my @uhost_2 = uniq sort @host_2;

print "strict digraph UGB {
	graph \[overlap=false, splines=ortho, rankdir=\"LR\" \];
	edge \[ arrowhead=\"inv\", color=\"black\" \];
	node \[ style=\"filled,rounded\", width=7, fontname=\"monospace\" \];\n";

print "\tnode \[ fillcolor=\"aquamarine\", shape=\"box\" \];\n";
foreach (@uhost_1) { print "\t$_\n"; };
print "\tnode \[ shape=\"Mrecord\", fillcolor=\"darkgoldenrod1\" \];\n";
foreach (@uguest_1) { print "\t$_\n"; };

print "\tnode \[ fillcolor=\"aquamarine\", shape=\"box\" \];\n";
foreach (@uhost_2) { print "\t$_\n"; };
print "\tnode \[ shape=\"Mrecord\", fillcolor=\"darkgoldenrod1\" \];\n";
foreach (@uguest_2) { print "\t$_\n"; };

print "\tsubgraph cluster_0 {\n\t\tlabel=\"2\";\n\t\tstyle=\"filled\";\n\t\tcolor=\"lightgrey\";\n";
foreach (sort @con_1) { print "\t\t$_\n"; };
print "\t};\n";

print "\tsubgraph cluster_1 {\n\t\tlabel=\"2\";\n\t\tstyle=\"filled\";\n\t\tcolor=\"lightblue\";\n";
foreach (sort @con_2) { print "\t\t$_\n"; };
print "\t};\n";
print "}";
