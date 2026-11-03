if [ -d "$BATS_TEST_DIRNAME/../node_modules/bats-support" ]; then
    bats_lib_dir="$BATS_TEST_DIRNAME/../node_modules"
else
    bats_lib_dir=/usr/lib/bats
fi
load "$bats_lib_dir/bats-support/load.bash"
load "$bats_lib_dir/bats-assert/load.bash"
load dns
