# Security Policy

## Supported Versions

This gives guidance about which branches are supported with patches to
security vulnerabilities.

| Version / branch  | Supported                                            |
| ---------  | ---------------------------------------------------- |
| main       | :white_check_mark: :construction: ALL fixes immediately, but this is a branch under development with a frequently unstable ABI and occasionally unstable API. |
| 3.6.0.x    | :white_check_mark: All fixes that can be backported without breaking ABI compatibility. New tagged releases monthly. |
| <= 3.6.0.1 | :x: No longer receiving patches of any kind. |


## Reporting a Vulnerability

If you think you've found a potential vulnerability in MoonRay, please report it
by emailing the project administrators at
[security@moonray.org](security@moonray.org). Only the
project administrators have access to these messages. Include detailed steps to
reproduce the issue, and any other information that could aid an
investigation. Our policy is to respond to vulnerability reports within 14
days.

Our policy is to address critical security vulnerabilities rapidly and post
patches as quickly as possible.

## Security Expectations

### Software Features

- MoonRay and its related CLI tools read and execute RDLA files in a Lua
  interpreter. These files are expected to be provided by the user, and are not
  expected to be provided by untrusted sources. If you are using RDLA files from
  untrusted sources, you should be aware that they could cause any type of issue
  that would ordinarily be causable as the result of an arbitrary code execution.

- MoonRay plugins can, by definition and by design, result in the execution of
  arbitrary code. It is critical that users of MoonRay maintain their own strict
  control over their own plugins, and not trust arbitrary plugins given to them
  by unknown sources. MoonRay takes no responsibility for malicious effects
  caused by that execution of code.

### Potential Vulnerabilities

It is expected that maliciously crafted plugins, or RDLA files, could cause any
type of issue that would ordinarily be causable as the result of a Lua file load,
or an arbitrary code execution. Do not use or consume packages or context files
provided from untrusted sources without undue validation, care, or sandboxing.


## Outstanding Security Issues

None known


## History of CVE Fixes

