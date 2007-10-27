# Load the Module::Install bundled in ./inc/
use inc::Module::Install;

# Define metadata
name           'IncPatch';
all_from       'lib//IncPatch.pm';

requires       'Moose';
requires       'Term::ReadKey';
requires       'Term::CallEditor';
requires       'IO::Pager';

build_requires 'Test::More';

install_script 'bin/incpatch';

auto_install;
WriteAll;

