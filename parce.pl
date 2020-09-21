use 5.010;
use List::MoreUtils qw/uniq/;

my $file = "vmware_rep.csv";
open my $fh, "<", $file
	or die "can not open $file: $!";
my @host_ss, @host_vh, @guest_ss, @guest_vh, @con_ss, @con_vh;

foreach (<$fh>) {
	chomp;
	my @line = split /,/, $_;
	my $gueststr = "\"$line[0]\" \[ label=\"Name: $line[0]\\l|. . . IP: $line[2]\\l|. . . DNS: $line[11]\\l|. . . OS: $line[5]\\l|. . . CPU: $line[7], Mem: $line[6]\\l|. . . Space: $line[3], Cluster: $line[10]\\l\" \];";
	$line[1] =~ s/.fuu.local//;
	my $hoststr = "\"$line[1]\" \[ label=\"Name: $line[1]\\l\\n. . . $line[12]\\l\\n. . . $line[13]\\l\" \];";
	my $connectstr = "\"$line[1]\" -> \"$line[0]\";";
	if ($line[1] =~ /p$/) {
		push(@host_vh, $hoststr);
		push(@con_vh, $connectstr);
		push(@guest_vh, $gueststr);
	} else {
		push(@host_ss, $hoststr);
		push(@con_ss, $connectstr);
		push(@guest_ss, $gueststr);
	};
};

my @uguest_ss = uniq sort @guest_ss;
my @uguest_vh = uniq sort @guest_vh;

my @uhost_ss = uniq sort @host_ss;
my @uhost_vh = uniq sort @host_vh;

print "strict digraph G {
	graph \[overlap=false, splines=ortho, rankdir=\"LR\" \];
	edge \[ arrowhead=\"inv\", color=\"black\" \];
	node \[ style=\"filled,rounded\", width=7, fontname=\"monospace\" \];\n";

print "\tnode \[ fillcolor=\"aquamarine\", shape=\"box\" \];\n";
foreach (@uhost_ss) { print "\t$_\n"; };
print "\tnode \[ shape=\"Mrecord\", fillcolor=\"darkgoldenrod1\" \];\n";
foreach (@uguest_ss) { print "\t$_\n"; };

print "\tnode \[ fillcolor=\"aquamarine\", shape=\"box\" \];\n";
foreach (@uhost_vh) { print "\t$_\n"; };
print "\tnode \[ shape=\"Mrecord\", fillcolor=\"darkgoldenrod1\" \];\n";
foreach (@uguest_vh) { print "\t$_\n"; };

print "\tsubgraph cluster_0 {\n\t\tlabel=\"SS\";\n\t\tstyle=\"filled\";\n\t\tcolor=\"lightgrey\";\n";
foreach (sort @con_ss) { print "\t\t$_\n"; };
print "\t};\n";

print "\tsubgraph cluster_1 {\n\t\tlabel=\"HV\";\n\t\tstyle=\"filled\";\n\t\tcolor=\"lightblue\";\n";
foreach (sort @con_vh) { print "\t\t$_\n"; };
print "\t};\n";
print "}";
