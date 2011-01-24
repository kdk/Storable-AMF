#===============================================================================
#
#         FILE:  66-boolean-3.t
#         COMMENT code taken from boolean-patch 
#===============================================================================


use strict;
use warnings;
use ExtUtils::testlib;
use Storable::AMF0 qw(parse_option freeze thaw new_amfdate);
use Storable::AMF  qw(thaw0 freeze0 thaw3 freeze3);
use Data::Dumper;
use Devel::Peek;

sub boolean{
	return bless \(my $s = $_[0]), 'boolean';
}
sub true(){
	return boolean(1); 
}
sub false(){
	return boolean('');
}
sub JSON::XS::true{
	return bless \(my $o = 1), "JSON::XS::Boolean" ;
}
sub JSON::XS::false{
	return bless \(my $o = 0), "JSON::XS::Boolean";
}

my $total = 13 + 6 + 6;
eval "use Test::More tests=>$total;";
warn $@ if $@;
my $nop = parse_option('prefer_number, json_boolean');
our $var;
#goto ABC;

# constants
ok( !is_amf_boolean ( ! !1 ),    'perl bool context not converted(t)');
ok( !is_amf_boolean ( ! !0 ),    'perl bool context not converted(f)');
ok( is_amf_boolean ( true ),   '"boolean" true');
ok( is_amf_boolean ( false ),   '"boolean" false');
ok( is_amf_boolean ( JSON::XS::true ),   'JSON::XS::true');
ok( is_amf_boolean ( JSON::XS::false ),   'JSON::XS::false');

# Vars
ok( !is_amf_boolean ( $a = 4 ),      'int var');
ok( !is_amf_boolean ( $a = 4.0 ), 'double var');
ok( !is_amf_boolean ( $a = "4" ),     'str var');
ok( is_amf_boolean (  $a = JSON::XS::true ),  'JSON::XS bool var');
ok( is_amf_boolean (  $a = true ),  'boolean var');
ok( is_amf_boolean (  $a = JSON::XS::false ),  'JSON::XS bool var');
ok( is_amf_boolean (  $a = false ),  'boolean var');


ABC:
my $json_true = JSON::XS::true;
my $json_false = JSON::XS::false;
my $boolean_true = true;
my $boolean_false = false;

my $object = {
    a => {a => 1},
    jxb1 => $json_true,
    jxb2 => $json_true,
    c => {a => 1, jxb3 => $json_true },
};
# AMF0 roundtrip
is_deeply( amf0_roundtrip($object), $object, "roundtrip multi-bool (A0)" );
is_deeply( amf0_roundtrip( true ), $json_true, '"boolean" comes back as JSON::XS (A0)' );
# AMF3 roundtrip
is_deeply( amf3_roundtrip($object), $object, "roundtrip multi-bool (A3)" );
is_deeply( amf3_roundtrip( true ), $json_true, '"boolean" comes back as JSON::XS (A3)' );

# AMF0 Added more accurate tests 
isa_ok( amf0_roundtrip( true ) , "JSON::XS::Boolean" );
isa_ok( amf0_roundtrip( $json_true ) , "JSON::XS::Boolean" );
isa_ok( amf0_roundtrip( false ) , "JSON::XS::Boolean" );
isa_ok( amf0_roundtrip( $json_false ) , "JSON::XS::Boolean" );

# AMF3 Added more accurate tests 
isa_ok( amf3_roundtrip( true ) , "JSON::XS::Boolean" );
isa_ok( amf3_roundtrip( $json_true ) , "JSON::XS::Boolean" );
isa_ok( amf3_roundtrip( false ) , "JSON::XS::Boolean" );
isa_ok( amf3_roundtrip( $json_false ) , "JSON::XS::Boolean" );
sub is_amf_boolean{
	is_amf0_boolean( $_[0] ) && is_amf3_boolean( $_[0] );
}
sub is_amf0_boolean{
	ord( freeze0( $_[0], )) == 1;
}
sub amf0_roundtrip {
    my $src = shift;
	my $amf = freeze0( $src );
    my $struct = thaw0($amf, $nop);
    return $struct;
}
sub is_amf3_boolean{
	my $header = ord( freeze3( $_[0] ));
	return $header == 2 || $header == 3;
}
sub amf3_roundtrip {
    my $src = shift;
	my $amf = freeze3( $src );
    my $struct = thaw3($amf, $nop);
    return $struct;
}
