# Contributing to Catspeak

Thank you for being interested in contributing to Catspeak. Please don't try to
push directly to this repo, it wont work. Instead, fork this repo and make your
changes there.

For more information, read the guidelines supplied by [GitHub](https://docs.github.com/en/get-started/quickstart/contributing-to-projects).

## Contributing Guidelines

### Issues

If you notice a problem with Catspeak, feel free to create an issue using the
[issue form](https://github.com/katsaii/catspeak-lang/issues/new). If you have
multiple issues you want to report, please report them separately instead of as
a monolithic task. Once you have created an issue, it may be updated with
[certain tags](https://github.com/katsaii/catspeak-lang/labels) depending on its
content.

If you would like to work on solving an issue, feel free to pick one and work
on it. I wont assign issues to anyone.

### Commit messages

This isn't necessarily  very important, but please try and keep commit messages
in the past tense and lower-case. Examples of commit messages include:
 - [added new `self` keyword](https://github.com/katsaii/catspeak-lang/commit/e839bac400aaf1874f4bf3e87487813a8354bff7)
 - [implemented 'or' logical operator](https://github.com/katsaii/catspeak-lang/commit/c432c6c21f53feaf7968c0e6453af548932e4844)
 - [updated README.md](https://github.com/katsaii/catspeak-lang/commit/18989abe7a8ebca0965ac1d6e77b596b0ca18340)

### Style

Please try your best to follow the style of any surrounding code. Here are some
brief tips:
 - Indentation uses 4 spaces, **please do not use tabs**.
 - Follow the [K&R](https://en.wikipedia.org/wiki/Indentation_style#K&R_style) style for brackets.
 - Do not use multi-line comments.
 - Do not exceed 80 characters per line.
 - Do not use legacy delphi keywords and operators, examples include:
   - `begin` and `end`
   - The `:=` assignment operator
   - The `=` and `<>` comparison operators
 - Ensure **all** statements end in a semi-colon.

I will still probably merge your PR if your code deviates from the style, but
please try and keep the codebase consistent.

### Testing

Running the developer project for Catspeak will also invoke the unit testing
framework. You can find these under `Testing/unit-tests` in the GameMaker IDE.

If you add new logic, please add a relevant unit test.

### Documentation

The documentation is generated completely automatically using a custom python
script located in the root directory of this project. For this reason, please
try to add good documentation to any new functions and methods.

However, if you don't want to write the documentation, please create an issue
mentioning which items are missing documentation so that someone else can look
into it.

#### Documentation Format

The general format of "doc comments" is similar to JSDoc, with some exceptions.
Below is a template which should be followed for doc comments attached to
functions and methods:
```js
/// Description for `catspeak_example`.
///
/// @param {TypeName} arg1
///   A short description of what `arg1` is used for.
///
/// @example
/// ```
/// // add a GML example of how to use `catspeak_example`
/// ```
///
/// @return {TypeName}
function catspeak_example(arg1) { ... }
```

All public functions should have **explicit** types for their arguments and
return types. The only exception to this is if the return type is `undefined`,
the `@return` tag does not need to be included.

You don't need to write documentation for internal functions.

#### Building the Documentation

1. Open a new terminal window.
2. Navigate to the root directory of this repo, you should see `build-docs.py`.
3. Run
   ```sh
   python ./build-docs.py
   ```

If you encounter no errors, then a new documentation page will be written to
`docs/index.html`.