# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _hub_repo_impl(rctx):
    for folder_name, spoke_file in rctx.attr.repo_mapping.items():
        # Get the absolute path to the spoke repository's root
        # using the label of a file in the root of the spoke repository.
        spoke_path = rctx.path(spoke_file).dirname

        # Symlink the entire spoke repo to a top-level folder in the hub
        rctx.symlink(spoke_path, folder_name)

    # Create a root BUILD file so Bazel recognizes these as packages
    rctx.file("BUILD.bazel", "# Hub Root")

hub_repo = repository_rule(
    implementation = _hub_repo_impl,
    attrs = {"repo_mapping": attr.string_keyed_label_dict(
        doc = "Map hub symlink names to spoke repositories.  The spoke repo should be the label of a file in the root of the spoke repo (e.g. BUILD.bazel)",
    )},
)

# Important note: this dictionary is read and modified by the release script (script/release.py).
# Therefore, it needs to remain a constant dictionary which can be parsed by the python ast module.
_ARCHIVES = {
    "presign_perso": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/PRESIGN_RELEASE_OT-SKU-TEST-RELEASE-1DD33B990A26536BFDA48AFEA06AB3F2F382F6C0-RUN-2/presign_perso.tar.xz",
        "sha256": "6ce543bc4455ea1dd698a492c306414d1c56168281013b98af8c97a12c218386",
    },
    "presign_rom_ext": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/PRESIGN_RELEASE_OT-SKU-TEST-RELEASE-1DD33B990A26536BFDA48AFEA06AB3F2F382F6C0-RUN-2/presign_rom_ext.tar.xz",
        "sha256": "6281c7de2a4f78fcdba308f298ef0f46dea80678b4cf03ff8278d227de505716",
    },
    "perso_release": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/FINAL_RELEASE_OT-SKU-TEST-RELEASE-1DD33B990A26536BFDA48AFEA06AB3F2F382F6C0-RUN-2/perso_release.tar.xz",
        "sha256": "efe176cf4cfbdb84b546b2ecdd6a9e3c6d2c9228baca4fcb8e397983fcc11d6f",
    },
    "rom_ext_release": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/FINAL_RELEASE_OT-SKU-TEST-RELEASE-1DD33B990A26536BFDA48AFEA06AB3F2F382F6C0-RUN-2/rom_ext_release.tar.xz",
        "sha256": "6edfaf3a199a5b63c1f0a24727463d58821a9e7df37c9f39ac204b575239af40",
    },
}

def _extra_impl(mctx):
    for (name, info) in _ARCHIVES.items():
        http_archive(
            name = name,
            **info
        )
    hub_repo(
        name = "provisioning_exts_extra",
        repo_mapping = {
            name: "@{}//:BUILD.bazel".format(name)
            for name in _ARCHIVES
        },
    )

extra = module_extension(
    implementation = _extra_impl,
)
