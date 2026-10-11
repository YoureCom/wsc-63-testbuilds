# WoltLab Suite 6.3 test builds (unofficial)

Daily, automatically built installation archives of the WoltLab Suite 6.3 development branch
([WoltLab/WCF](https://github.com/WoltLab/WCF), LGPL-2.1). **Early alpha. Never use it in production.**
This is a community project by [YoureCom](https://yourecom.de) and is not affiliated with WoltLab GmbH.

## Install

1. Pick the newest pre-release under *Releases* and download `WoltLabSuite-6.3-testbuild.zip`.
2. Unpack it and upload `install.php`, `test.php` and `WCFSetup.tar.gz` to an empty web directory (same folder).
   The files are also available one by one in the release.
3. Open `https://<your-domain>/install.php` and follow the wizard.

Requirements: PHP 8.4.23 to 8.5.x, MySQL/MariaDB, **HTTPS** (the wizard refuses plain HTTP).
Verify downloads with `sha256sum -c SHA256SUMS`. Updating an existing installation is not supported.

## How it works

`.github/workflows/build.yml` runs nightly, clones branch `6.3`, skips the run when that commit was
already built, runs `scripts/build.sh` (JS build, core package, `WCFSetup.tar.gz`) and publishes a
pre-release `6.3-alpha-<date>-<commit>`. `scripts/prune-releases.sh` keeps the last 7 builds plus one per week.

Report bugs in the build here. Bugs in the Suite itself belong to the Suite.
