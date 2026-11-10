fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios local_testflight

```sh
[bundle exec] fastlane ios local_testflight
```

Build & upload ke TestFlight dari lokal pakai Apple ID

### ios sync_certs

```sh
[bundle exec] fastlane ios sync_certs
```

Download development cert & profile (readonly, TIDAK butuh file .p8)

### ios renew_certs

```sh
[bundle exec] fastlane ios renew_certs
```

Buat/perbarui development cert & profile (butuh ASC API key)

### ios dev_patch_release

```sh
[bundle exec] fastlane ios dev_patch_release
```

Push to dev branch -> patch bump + TestFlight

### ios dev_build_release

```sh
[bundle exec] fastlane ios dev_build_release
```

Push to dev without bump patch version

### ios release

```sh
[bundle exec] fastlane ios release
```

GitHub Release published in main -> set version from tag + TestFlight

### ios renew_appstore_profile

```sh
[bundle exec] fastlane ios renew_appstore_profile
```

Admin only: buat/perbarui appstore profile lewat API key (tanpa login Apple ID)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
