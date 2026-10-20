load("@rules_cc//cc:defs.bzl", "cc_library")
load("//:defs.bzl", "clang_tidy_test")
load(":test.bzl", "transitive_arguments_test")

cc_library(
    name = "lib",
    srcs = ["lib.cc"],
    copts = ["-DFROM_LIB=1"],
)

cc_library(
    name = "app",
    srcs = ["main.cc"],
    deps = [":lib"],
)

# Aggregating target: analyze app, whose only compilable source of its own is
# main.cc, but which pulls lib.cc transitively through deps.
clang_tidy_test(
    name = "aggregate",
    tags = ["manual"],
    targets = [":app"],
)

transitive_arguments_test(
    name = "transitive_arguments",
    target_under_test = ":aggregate",
)
