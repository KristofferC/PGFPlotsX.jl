#!/bin/bash

JULIAVER=$1                     # the first and only argument to the script is the version
JULIABIN=/test/julia-$JULIAVER/bin/julia
PKGNAME="PGFPlotsX"

## install the image (when necessary)
/test/install-julia.sh $JULIAVER

cd /mnt && if [[ -a .git/shallow ]]; then git fetch --unshallow; fi

# run tests
$JULIABIN -e "import Pkg; Pkg.clone(\"/mnt/\", \"$PKGNAME\"); Pkg.build(\"$PKGNAME\"); Pkg.test(\"$PKGNAME\"; coverage=true)"
TEST_EXIT=$?                    # return with this

# save coverage results back to host
PKGDIR=`$JULIABIN -e "import Pkg, $PKGNAME; print(joinpath(dirname(pathof($PKGNAME)), ".."))"`
rsync -mav --include="*/" --include="*.cov" --exclude="*" $PKGDIR/ /mnt/
exit $TEST_EXIT
