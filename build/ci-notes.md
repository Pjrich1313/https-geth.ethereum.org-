# Debian Packaging

Tagged releases and develop branch commits are available as installable Debian packages
for Ubuntu. Packages are built for the all Ubuntu versions which are supported by
Canonical.

Packages of develop branch commits have suffix -unstable and cannot be installed alongside
the stable version. Switching between release streams requires user intervention.

## Launchpad

The packages are built and served by launchpad.net. We generate a Debian source package
for each distribution and upload it. Their builder picks up the source package, builds it
and installs the new version into the PPA repository. Launchpad requires a valid signature
by a team member for source package uploads.

The signing key is stored in an environment variable which Travis CI makes available to
certain builds. Since Travis CI doesn't support FTP, SFTP is used to transfer the
packages. To set this up yourself, you need to create a Launchpad user and add a GPG key
and SSH key to it. Then encode both keys as base64 and configure 'secret' environment
variables `PPA_SIGNING_KEY` and `PPA_SSH_KEY` on Travis.

We want to build go-ethereum with the most recent version of Go, irrespective of the Go
version that is available in the main Ubuntu repository. In order to make this possible,
we bundle the entire Go sources into our own source archive and start the built job by
compiling Go and then using that to build go-ethereum. On Trusty we have a special case
requiring the `~gophers/ubuntu/archive` PPA since Trusty can't even build Go itself. PPA
deps are set at https://launchpad.net/%7Eethereum/+archive/ubuntu/ethereum/+edit-dependencies

## Building Packages Locally (for testing)

You need to run Ubuntu to do test packaging.

Install any version of Go and Debian packaging tools:

    $ sudo apt-get install build-essential golang-go devscripts debhelper python-bzrlib python-paramiko

Create the source packages:

    $ go run build/ci.go debsrc -workdir dist

Then go into the source package directory for your running distribution and build the package:

    $ cd dist/ethereum-unstable-1.9.6+bionic
    $ dpkg-buildpackage

Built packages are placed in the dist/ directory.

    $ cd ..
    $ dpkg-deb -c geth-unstable_1.9.6+bionic_amd64.deb

## Exporting a Historical Commit

To capture a patch for a commit from a specific month and compare it to the current tree:
The lookup scans every reachable ref, so it can return a commit from either a branch or a tag.

    $ H=$(git rev-list --all -1 --since="2024-07-01 00:00:00" --until="2024-08-01 00:00:00")
    $ echo "Using commit from any branch/tag: $H"
    $ [ -z "$H" ] && echo "No commit found in July 2024 across all refs." && exit 1
    $ git cat-file -e "$H^{commit}" || { echo "Invalid commit: $H"; exit 1; }
    $ git show --stat --patch "$H" | head -200
    $ git format-patch -1 "$H" --stdout > "july-2024-$H.patch"
    $ git diff "$H..HEAD" > "july-2024-$H-to-HEAD.diff"
    $ ls -lh "july-2024-$H.patch" "july-2024-$H-to-HEAD.diff"
