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
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/PRESIGN_RELEASE_OT-SKU-TEST-RELEASE-875DADE1B1787D900EF46D63D82568B3EF6B2BE4-RUN-1/presign_perso.tar.xz",
        "sha256": "6eba86089a0daee4d5d3ec53899407ad11f3d8645c285c1618fba422827e6f33",
    },
    "presign_rom_ext": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/PRESIGN_RELEASE_OT-SKU-TEST-RELEASE-875DADE1B1787D900EF46D63D82568B3EF6B2BE4-RUN-1/presign_rom_ext.tar.xz",
        "sha256": "dd25fc7392d7ac9ee6ed51c29e64590a47c19a45fa832b99b76e16fc51c4c50c",
    },
    "perso_release": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/FINAL_RELEASE_OT-SKU-TEST-RELEASE-875DADE1B1787D900EF46D63D82568B3EF6B2BE4-RUN-1/perso_release.tar.xz",
        "sha256": "2028cff295e79baa5cb5eba7d39a85d5eb0897ef6eefc338239358bf382afe15",
    },
    "rom_ext_release": {
        "url": "https://github.com/lowRISC/ot-sku-testing/releases/download/FINAL_RELEASE_OT-SKU-TEST-RELEASE-875DADE1B1787D900EF46D63D82568B3EF6B2BE4-RUN-1/rom_ext_release.tar.xz",
        "sha256": "938f73703c52d59d39479f72a76892c4f100e0cd18cf27e7f637a898fdf502af",
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
