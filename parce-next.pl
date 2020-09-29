use 5.010;
use List::MoreUtils qw/uniq/;

my $file = "servers_VM.csv";
open my $fh, "<", $file or die "can not open $file: $!";
my (@hosts, @hostsStr, @guests, @guestsStr, @apps, @appsStr, @conHwVm, @conVmApp, @storages, @storagesStr, @conAppStor);

foreach (<$fh>) {
	chomp;
	my @line = split /,/, $_;
	
	my $dns = $line[0]; my $vmName = $line[1]; my $guestOS = $line[2]; my $host = $line[3];
	my $cluster = $line[4]; my $device = $line[5]; my $cpumodel = $line[6]; my $store = $line[7];
	my $space = $line[8]; my $mem = $line[10]; my $cpucount = $line[11]; my $uptime = $line[13];
	my $appl = "";
	if ($line[18] ne "") { $appl = "$line[18]\n"  };
	if ($line[19] ne "") { $appl = "$appl$line[19]\n"  };
	if ($line[21] ne "") { $appl = "$appl$line[21]\n"  };
	if ($line[22] ne "") { $appl = "$appl$line[22]\n"  };
	$appl =~ s/\n$//;

	my $fillG = "fillcolor=\"aquamarine\"";
	if ($store =~ /8020/) { $fillG = "fillcolor=\"red\"" };
	if ($uptime eq "0 second") {
		$fillG = "fillcolor=\"black\", fontcolor=\"yellow\"";
		$dns = "POWEROFF, $dns";
	};

	my $guestStr = "\"$vmName\" \[ label=\"{Name: $vmName\\l|. . . DNS: $dns\\l|. . . OS: $guestOS\\l|. . . CPU: $cpucount, Mem: $mem\\l|. . . Space: $space, Cluster: $cluster\\l}\", $fillG \];";
	
	my $fillH = "fillcolor=\"blue\"";
	$fillH = "fillcolor=\"gray\"" if ($host =~ /p$/);
	my $hostStr = "\"$host\" \[ label=\"Name: $host\\l\\n. . . $device\\l\\n. . . $cpumodel\\l\", $fillH \];"; 
	
	my $conHwVmStr = "\"$host\" -> \"$vmName\";";
	my $appStr = "\"$vmName.App\" \[ label=\"$appl\", fillcolor=\"lightgreen\" \];";
	my $conVmAppStr = "\"$vmName\" -> \"$vmName.App\";";
	
	my $storage = $store;
	$storage =~ s/.{2}_([a-zA-Z0-9]+)_.*/$1/;
	my $fillS = "fillcolor=\"blue\"";
	$fillS = "fillcolor=\"red\"" if ($storage eq "8020");
	my $storStr = "\"$storage\" \[ label=\"$storage\", $fillS \];";
	my $conAppStorStr = "\"$vmName.App\" -> \"$storage\";";
	
	push(@hosts, "\"$host\"");
	push(@hostsStr, $hostStr);
	push(@guests, "\"$vmName\"");
	push(@guestsStr, $guestStr);
	push(@apps, "\"$vmName.App\"");
	push(@appsStr, $appStr);
	push(@conHwVm, $conHwVmStr);
	push(@conVmApp, $conVmAppStr);
	push(@storages, $storage);
	push(@storagesStr, $storStr);
	push(@conAppStor, $conAppStorStr);
};

close $fh;

my @outHosts = uniq sort @hosts;
my @outGuests = uniq sort @guests;
my @outApps = uniq sort @apps;
my @outStorages = uniq sort @storages;

my @outHostsStr = uniq sort @hostsStr;
my @outGuestsStr = uniq sort @guestsStr;
my @outAppsStr = uniq sort @appsStr;
my @outStoragesStr = uniq sort @storagesStr;

print "strict digraph G {
	layout=\"neato\";
	graph \[overlap=\"false\", splines=\"ortho\" \];
	edge \[ color=\"black\", minlen=40 \];
	node \[ shape=\"box\", style=\"filled,rounded\", width=6, fontname=\"monospace\" \];
	{\n";
foreach (@outHostsStr) { print "\t\t$_\n" };
print "\t}\n\t{\n\t\tnode [ shape=\"Mrecord\" \];\n";
foreach (@outGuestsStr) { print "\t\t$_\n" };
print "\t}\n\t{\n";
foreach (@outAppsStr) { print "\t\t$_\n" };
print "\t}\n\t{\n";
foreach (@outStoragesStr) { print "\t\t$_\n" };
print "\t}\n\t{\n\t\tgraph [rank=\"same\"];\n";
foreach (@outHosts) { print "\t\t$_;\n" };
print "\t}\n\t{\n\t\tgraph [rank=\"same\"];\n";
foreach (@outGuests) { print "\t\t$_;\n" };
print "\t}\n\t{\n\t\tgraph [rank=\"same\"];\n";
foreach (@outApps) { print "\t\t$_;\n" };
print "\t}\n\t{\n\t\tgraph [rank=\"same\"];\n";
foreach (@outStorages) { print "\t\t$_;\n" };
print "\t}\n\t{\n";
foreach (@conHwVm) { print "\t\t$_\n" };
foreach (@conVmApp) { print "\t\t$_\n" };
foreach (@conAppStor) { print "\t\t$_\n" };
print "\t}\n";
print "}\n";
