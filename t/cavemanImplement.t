##########LICENCE##########
#  Copyright (c) 2014-2018 Genome Research Ltd.
#
#  Author: CASM/Cancer IT <cgphelp@sanger.ac.uk>
#
#  This file is part of cgpCaVEManWrapper.
#
#  cgpCaVEManWrapper is free software: you can redistribute it and/or modify it under
#  the terms of the GNU Affero General Public License as published by the Free
#  Software Foundation; either version 3 of the License, or (at your option) any
#  later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
#  details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
##########LICENCE##########

use strict;
use Test::More;
use File::Spec;
use Const::Fast qw(const);
use FindBin qw($Bin);

const my $MODULE => 'Sanger::CGP::Caveman::Implement';
const my $LINES_PER_FQ => 4;

my $test_data = "$Bin/../testData";

my $good_fq = File::Spec->catfile($test_data, '1_2.fq');
my $bad_fq = File::Spec->catfile($test_data, '1_2_bad.fq');
my $out_prefix = File::Spec->catfile($test_data, 'sample');
my $fai = File::Spec->catfile($test_data, 'genome.fa.fai');
my $tmp = $test_data;

subtest 'Initialisation checks' => sub {
  use_ok($MODULE);
};

subtest 'Line count checks' => sub {
	is(Sanger::CGP::Caveman::Implement::file_line_count($good_fq),$LINES_PER_FQ,'Line count correct');
	isnt(Sanger::CGP::Caveman::Implement::file_line_count($bad_fq),$LINES_PER_FQ,'Line count correct (2)');
};

subtest 'exclude contig checks' => sub {
  my $idx = Sanger::CGP::Caveman::Implement::valid_seq_indexes({'reference' => $fai, 'exclude' => 'GL%'});
  is(scalar @{$idx}, 27, 'Limiting to require contigs via exclude');
};

subtest 'Indicies limits' => sub {
  my $options = {'splitList' => $good_fq};
  my @indicies = Sanger::CGP::Caveman::Implement::limited_xstep_indicies($options, 1);
  is(scalar @indicies, 1, 'No limit, single value');
  is($indicies[0], 1, 'No limit, single value=1');
  $options->{'limit'} = 4;
  @indicies = Sanger::CGP::Caveman::Implement::limited_xstep_indicies($options, 1);
  is(scalar @indicies, 1, 'Limit matches max jobs, single value');
  is($indicies[0], 1, 'Limit matches max jobs, single value=1');
  $options->{'limit'} = 2;
  @indicies = Sanger::CGP::Caveman::Implement::limited_xstep_indicies($options, 1);
  is(scalar @indicies, 2, 'Limit = max jobs/2, 2 values (index_in=1)');
  is($indicies[0], 1, 'Limit = max jobs/2, value[0]=1 (index_in=1)');
  is($indicies[1], 3, 'Limit = max jobs/2, value[1]=3 (index_in=1)');
  @indicies = Sanger::CGP::Caveman::Implement::limited_xstep_indicies($options, 2);
  is(scalar @indicies, 2, 'Limit = max jobs/2, 2 values (index_in=2)');
  is($indicies[0], 2, 'Limit = max jobs/2, value[0]=2 (index_in=2)');
  is($indicies[1], 4, 'Limit = max jobs/2, value[1]=4 (index_in=2)');
};

subtest 'Indicies limits file count' => sub {
	my $options = {'vcf_split_count' => 4};
	my @indicies = Sanger::CGP::Caveman::Implement::limited_flag_indicies($options, 1);
  is(scalar @indicies, 1, 'No limit, single value');
  is($indicies[0], 1, 'No limit, single value=1');
  $options->{'limit'} = 4;
  @indicies = Sanger::CGP::Caveman::Implement::limited_flag_indicies($options, 1);
  is(scalar @indicies, 1, 'Limit matches max jobs, single value');
  is($indicies[0], 1, 'Limit matches max jobs, single value=1');
  $options->{'limit'} = 2;
  @indicies = Sanger::CGP::Caveman::Implement::limited_flag_indicies($options, 1);
  is(scalar @indicies, 2, 'Limit = max jobs/2, 2 values (index_in=1)');
  is($indicies[0], 1, 'Limit = max jobs/2, value[0]=1 (index_in=1)');
  is($indicies[1], 3, 'Limit = max jobs/2, value[1]=3 (index_in=1)');
  @indicies = Sanger::CGP::Caveman::Implement::limited_flag_indicies($options, 2);
  is(scalar @indicies, 2, 'Limit = max jobs/2, 2 values (index_in=2)');
  is($indicies[0], 2, 'Limit = max jobs/2, value[0]=2 (index_in=2)');
  is($indicies[1], 4, 'Limit = max jobs/2, value[1]=4 (index_in=2)');
};

done_testing();
