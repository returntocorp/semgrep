# Simple

## Example semgrep Patterns

### Expression Matching

```text
pattern: 1 + foo(42)

# CODE EXAMPLES

foobar(1 + foo(42)) + whatever()
```

### Metavariables

```text
pattern: $X + $Y

# CODE EXAMPLES

foo() + bar()
```

**Matching Identifiers**

```text
pattern: import $X

# CODE EXAMPLES

import random
```

**Reusing Metavariables**

```text
pattern: ￼$X == $X

# CODE EXAMPLES

1+2 == 1+2
```

### Function Calls

```text
pattern: foo(...)

# CODE EXAMPLES

foo(1,2)
```

The above will not match patterns like `obj.foo(1,2)` because the AST for a function differs from a method call internally.

**With Arguments After a Match**

```text
pattern: foo(1, ...)

# CODE EXAMPLES

foo(1, "extra stuff", False)
foo(1) # matches no arguments as well
```

**With Arguments Before a Match**

```text
pattern: foo(..., 1, ...)

# CODE EXAMPLES

foo(1, 2)
foo(2, 1)
foo(2, 3, 1)
```

**Object with Method Call**

```text
pattern: $X.get(..., None)

# CODE EXAMPLES

json_data.get('success', None)
```

**Keyword Arguments in Any Order**

```text
pattern: foo(kwd1=$X, err=$Y)

# CODE EXAMPLES (keyword arguments in arbitrary order)

foo(err=False, kwd1=True)
```

### String Matching

**Using the ‘...’ Operator**

```text
pattern: foo("...")

# CODE EXAMPLES

foo("this is a specific string")
```

**Using** [**OCaml regular expression**](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Str.html) **Patterns**

```text
pattern: foo("=~/.*a.*/")

# CODE EXAMPLES

foo("this has an a")
```

### Conditionals

```text
pattern: |
    if $X:
        $Y

# CODE EXAMPLES

if __name__ == "__main__":
    print('hello world')
```

```text
pattern: |
    if $X:
        ...

# CODE EXAMPLES

if __name__ == "__main__":
    print('hello world')
    foo()
    bar()
```

Note you can’t match a half statement; both of the examples above must specify the contents of the condition’s body \(e.g. `$Y` and `...`\), otherwise they are not valid AST elements.

### In a statement context, a Metavariable can also match any statement

```text
pattern: |
    if $X:
        $Y

# CODE EXAMPLES
if 1:
  foo()

if 2:
  return 1

if 3:     # matches a “block” (a single statement containing multiple statements)
  foo()
  bar()
```

Because in Python there is usually no terminator \(e.g., `;`\), there is an ambiguity about `$Y` in the above, which could match a statement and also an expression that is then matched later.

### Match on import types

```text
pattern: subprocess.Popen(...)

# CODE EXAMPLES

import subprocess as s
s.Popen()
```

## Limitations

### semgrep is not grep

```text
'foo'
which is parsed as an expression pattern, will match code like
foo()
bar+foo
foo(1,2)

but will not match code like
import foo

because in the above, foo is not an expression, but rather a name part of an import statement.
```

### You can not use a half expression or half statement pattern

```text
'1+'  or 'if $X:' are not valid patterns because they are not full AST elements.
```

## Contributions & Ideas

Have an idea? Fork the code, or file an issue!

