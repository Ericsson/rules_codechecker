# Tests:

## Running Tests

Our projects use both **`bazel tests`** and **`pytest`**.
You can run bazel tests with: `bazel test //...`.
For more verbosity in python tests use **`-vvv`** or **`--log-cli-level=DEBUG`** for pytest.

### To run all unit tests, use one of the following command:
* **Using Pytest:**
    ```bash
    pytest unit -vvv
    ```

* **Using Unittest:**
    ```bash
    python3 -m unittest discover unit -vvv
    ```

### Running a Subset of Tests
Specify the directory containing your desired tests. For example, to run tests in `my_test_dir`:

```bash
pytest unit/my_test_dir -vvv
# OR
python3 -m unittest discover unit/my_test_dir -vvv
```

## Adding New Unit Tests

1. **Create a Test Folder**  
   Inside the `unit` directory, create a folder for your new test. This folder should contain:
   - All source/header files needed for the test
   - `BUILD`

2. **Creating the BUILD File**
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

3. **Create a python test if you must**
    - If you are writing a python test, have an `__init__.py` file in the test directory!
    - Your test script must follow the naming convention:
        ```text
        test_*.py
        ``` 
    - At the top of your test file, include the following snippet to correctly handle module imports:
        ```python
        from common.base import TestBase
        ```  
    - Create your test class by extending `TestBase` and implement your test methods.
> [!WARNING]
> You should include this line in your test class, this sets the current working directory:
> ```python
> __test_path__ = os.path.dirname(os.path.abspath(__file__))
> ```

**For a test template look into unit/template**

## Testing on open source projects

### To run all FOSS tests, use one of the following command:
* **Using Pytest:**
    ```bash
    pytest foss -vvv
    ```

* **Using Unittest:**
    ```bash
    python3 -m unittest discover foss -vvv
    ```

## Add a new open source project:

1. Create a folder in the foss folder with the name of the project.
2. The folder should contain:
    - init.sh

3. The init.sh script should:
  - Take the folder to which the project should be cloned/downloaded as the single command line argument
  - Clone the test project into said folder
  - To ensure the project doesn't change over time, check out a specific tag or commit instead of a branch!
  - Copy the .bazelversion file, if it exists, from the root of codechecker_bazel into the projects directory.
    This file is usually set by developers using bazelisk, and is also used in CI.
  - Append the WORKSPACE.template file to the WORKSPACE file of the project.
  - Append the codechecker rules to the BUILD file of the project.
    - There can be only two targets, codechecker_test and per_file_test
