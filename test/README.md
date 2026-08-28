# Tests:

## Running Tests

Our projects use both **`bazel tests`** and **`pytest`**.
You can run bazel tests with: `bazel test //...`.
For more verbosity in python tests use **`-vvv`** or **`--log-cli-level=DEBUG`** for pytest.

### To run all python tests, use one of the following command:
* **Using Pytest:**
    ```bash
    pytest unit -vvv
    ```

* **Using Unittest:**
    ```bash
    python3 -m unittest discover unit -vvv
    ```


## Adding New Unit Tests

### Create a Test Folder
   Inside the `unit` directory, create a folder for your new test. This folder should contain:
   - All source/header files needed for the test
   - `BUILD`

---
### Create a skylib test

With skylib we can test anything that does not use the output of
`ctx.actions.run` actions (i.e. anything known at analysis time).
Skylib provides two different kinds of tests: **unit tests** and
**analysis tests**.

For more in depth information check the skylib documentation for [analysis](https://github.com/bazelbuild/bazel-skylib/blob/main/docs/analysis_test_doc.md) and [unit tests](https://github.com/bazelbuild/bazel-skylib/blob/main/docs/unittest_doc.md).

- **Unit tests** assert on a single Starlark function — call it with
    known inputs and check the return value.
- **Analysis tests** build a real Bazel target and then inspect the
    providers it returns (e.g. `DefaultInfo`, `CcInfo`, or custom
    providers) without executing any actions.

Both are created in a `.bzl` file, instantiated from a `BUILD` file,
and run with `bazel test`.

#### Analysis tests

See a small example in `test/unit/basic/analysis_test.bzl`.
An analysis test has three parts:

a. An **implementation function** that receives the test environment,
    retrieves the target under test, and makes assertions on its
    providers. (must start with `analysistest.begin(ctx)` and end with `return analysistest.end(env)`)
b. A **test rule** created with `analysistest.make()`.
c. **Instantiation** in the `BUILD` file where the test rule is called
    with `target_under_test` pointing to the subject target.

##### Skeleton `.bzl` file

```starlark
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _my_test_impl(ctx):
    env = analysistest.begin(ctx)

    # Retrieve the target being tested.
    target = analysistest.target_under_test(env)

    # Make assertions on its providers.
    asserts.true(
        env,
        SomeProvider in target,
        "Target should provide SomeProvider",
    )

    return analysistest.end(env)

my_test = analysistest.make(_my_test_impl)
```

###### Custom attributes

If your test needs configurable expected values, pass an `attrs` dict
to `analysistest.make()`:

```starlark
my_test = analysistest.make(
    _my_test_impl,
    attrs = {
        "expected_value": attr.string(default = "hello"),
    },
)
```

Access them in the implementation with `ctx.attr.expected_value`.

###### Testing aspects

If your rule uses an aspect, tell the test to apply it with
`extra_target_under_test_aspects`:

```starlark
my_aspect_test = analysistest.make(
    _my_aspect_test_impl,
    extra_target_under_test_aspects = [my_aspect],
)
```

This makes the aspect's providers available on the target under test.

##### Skeleton `BUILD` file

```starlark
load(":my_test.bzl", "my_test")

# Subject target — what we are testing.
# Always tag "manual" so it isn't built outside the test.
cc_library(
    name = "my_subject",
    srcs = ["testdata/foo.cc"],
    defines = ["MY_DEFINE=1"],
    tags = ["manual"],
)

# Analysis test — points at the subject.
my_test(
    name = "my_analysis_test",
    target_under_test = ":my_subject",
)
```

#### Test suites

When you have multiple related analysis tests, group them with a
test-suite macro. This keeps the `BUILD` file readable and lets you
run the whole group with one target:

```starlark
def my_test_suite(name):
    first_test(
        name = name + "_first",
        target_under_test = ":" + name + "_first_subject",
    )
    second_test(
        name = name + "_second",
        target_under_test = ":" + name + "_second_subject",
    )

    native.test_suite(
        name = name,
        tests = [
            ":" + name + "_first",
            ":" + name + "_second",
        ],
    )
```

#### Assertions

Commonly used assertions from `@bazel_skylib//lib:unittest.bzl`:

| Function | Purpose |
|---|---|
| `asserts.true(env, cond, msg)` | Condition is true |
| `asserts.false(env, cond, msg)` | Condition is false |
| `asserts.equals(env, expected, actual)` | Equality check |
| `asserts.new_set_equals(env, expected, actual)` | Set equality |

Always include a descriptive failure message — skylib error output can
be cryptic without one.

### Unit tests

For a small example see `test/unit/basic/unit_test.bzl`.

A skylib unit test calls a pure Starlark function directly and asserts
on its return value. Use it when you don't need a full Bazel target.

```starlark
load("@bazel_skylib//lib:unittest.bzl", "unittest", "asserts")

def _my_unit_test_impl(ctx):
    env = unittest.begin(ctx)

    result = my_function("input")
    asserts.equals(env, "expected", result)

    return unittest.end(env)

my_unit_test = unittest.make(_my_unit_test_impl)

def my_unit_test_suite(name):
    my_unit_test(name = name + "_my_unit_test")

    native.test_suite(
        name = name,
        tests = [":" + name + "_my_unit_test"],
    )
```

Then in `BUILD`:

```starlark
load(":my_test.bzl", "my_unit_test_suite")

my_unit_test_suite(name = "my_tests")
```

---
### Creating unit tests asserting on the output of a rule

We can test the output of `ctx.actions.run` actions using the `unit_test` macro found in `test/unit/unit_test.bzl`.
You may use the tests under `test/unit/basic` as template.
- Create the `cc_binary/library` targets.
- Create the `codechecker_test` targets.
- Create `unit_test` targets to assert on the outputs of the codechecker targets. (See `unit/unit_test.bzl` for documentation)
- Make sure that all failing `codechecker_test` targets get the `"manual"` tag. For example:
```
# This is a test I expect to fail
codechecker_test(
    name = "codechecker_fail",
    tags = [
        "manual",
    ],
    targets = [
        "test_fail",
    ],
)
```
- Tip: To test these failing tests, create a unit_test target and assert the bug being found.

---
### Create a custom python test if you must
    
    In case you are writing integration tests, or tests that cannot be satisfied by the previous two solutions,
    create a custom `py_test` target. To make thing nicer wrap the py_test into a macro like with `unit_test.blz`.

    For reference you may use:
    - `test/unit/unit_test.bzl`
    - `test/foss`
    - `test/caching`

## Testing on open source projects

You can run all FOSS test with `bazel test //test/foss:*`.

## Add a new open source project:

Add a new `foss_test` target to the BUILD file in `test/foss`.
For each foss test you have to:
    - Give an url to an archive of the codebase (get it from the releases page).
    - In case the name of the target you want to test on differs from the name given to the test, define it with `target`.
    - Define which tests should be run. (possible values are: `":codechecker_per_file"`, `":codechecker_test"`, `":compile_commands"`)

Example:
```python
foss_test(
    name = "cpuinfo_bazel",
    target = "cpuinfo",
    tests = [
        ":codechecker_per_file",
        ":codechecker_test",
        ":compile_commands",
    ],
    url = "https://github.com/pytorch/cpuinfo/archive/66ee79c0.tar.gz",
)
```
