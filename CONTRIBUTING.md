# Contributing to MoonRay

Thank you for your interest in contributing to MoonRay!  This document explains our contribution process and procedures.

## Community and Discussion

The [Discussions](https://github.com/DreamWorksAnimation/OpenMoonRay/discussions) panel of the main Open MoonRay GitHub repository is used for asking questions, starting discussions, making announcements, and general engagement with the MoonRay community.

## Bug Reports and Issue Tracking

The [Issues](https://github.com/DreamWorksAnimation/OpenMoonRay/issues) panel of the main Open MoonRay GitHub repository is used to report bugs and build issues, and requesting enhancements.

## Legal Requirements

### License

MoonRay is licensed under the [Apache 2.0 license](LICENSE). Contributions to the project should abide by that standard license.

### Contributor License Agreement (CLA)

Developers who wish to contribute code to be considered for inclusion
in the MoonRay project must first complete a **Contributor
License Agreement**.

To contribute to MoonRay, you must sign a CLA through the
[EasyCLA](https://docs.linuxfoundation.org/lfx/easycla)
system, which is integrated with GitHub as a pull request check.

If a contributor opens a pull request without having a CLA on file, the 
contributor will be guided through the process to have the appropriate 
CLA signed. Look in the PR comments for the "linux-foundation-easycla" 
check that would fail, and a red "NOT COVERED" button will appear in the PR
comments; click the link in the comment to sign the CLA. For organizations, 
you can alternatively go to [this
link](https://organization.lfx.linuxfoundation.org/foundation/a09410000182dD2AAI/project/a092M00001If9ujQAB/cla)
prior to submitting a pull request, which will guide you through the 
process to have a CLA signed on behalf of the organization.

* If you are an individual writing the code on your own time and
  you're **sure** you are the sole owner of any intellectual property you
  contribute, you can sign the CLA as an **Individual Contributor**. If you
  are unsure, please contact your employer for clarity.

* If you are writing the code as part of your job, or if your employer
  retains ownership to intellectual property you create, no matter how
  small, then your company's legal affairs representatives should sign
  a **Corporate Contributor Licence Agreement**. If your company already
  has a signed CCLA on file, ask your local CLA manager to add you
  (via your GitHub account name/email address) to your company's
  "approved" list.

The downloadable PDF's on the EasyCLA page are provided for reference
only. To execute the signature, sign the form online through the
relevant links.

The MoonRay CLAs are the standard forms used by the Linux Foundation
projects and [recommended by the ASWF
TAC](https://github.com/AcademySoftwareFoundation/tac/blob/main/process/contributing.md#contributor-license-agreement-cla). 
Note that if you have signed a CLA for a different ASWF or LF project, that 
CLA doesn't apply here and you need to sign for this project specifically.

### Developer Certificate of Origin (DCO)

The MoonRay project requires the use of the [Developer Certificate of Origin 1.1 (DCO)](https://developercertificate.org/), which affirms that the contribution was created by you the contributor, and that you have the rights to contribute the changes under the open source license. It is the same mechanism that the  [Linux® Kernel](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/process/submitting-patches.rst#n416) and many other communities use to manage code contributions. The DCO is considered one of the simplest tools for sign offs from contributors as the representations are meant to be easy to read and indicating signoff is done as a part of the commit message.

Here is an example Signed-off-by line, which indicates that the submitter accepts the DCO:
```
Signed-off-by: John Doe <john.doe@example.com>
```

You can include this automatically when you commit a change to your local git repository using `git commit -s`. You might also want to leverage this [command line tool](https://github.com/coderanger/dco) for automatically adding the signoff message on commits.

[Read more about MoonRay legal and licensing concerns for contributions here](https://docs.openmoonray.org/license/).

## Repository Structure

MoonRay is available as a number of repositories on GitHub. The main repository is [`openmoonray`](README.md), and it [references all the other repositories](.gitmodules) required to build MoonRay as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

Some of the MoonRay repositories use [Git Large File Storage (LFS)](https://git-lfs.com/) to track larger files like images. Ensure that Git LFS is installed prior to cloning the MoonRay project:
```
git lfs install
```
To clone the entire code base needed to build MoonRay, including submodules:
```
git clone --recurse-submodules https://github.com/dreamworksanimation/openmoonray.git
```

[Read more about the MoonRay source structure here](https://docs.openmoonray.org/developer-reference/source-structure/).

## Development and Pull Requests

Contributions to MoonRay should be submitted as GitHub Pull Requests. See the [GitHub Pull Request documentation](https://help.github.com/articles/using-pull-requests/) to learn about this process if you are unfamiliar. 

All code must be formally reviewed before being merged into the repository.

The development cycle for a code change should follow the following process:

1. Create a GitHub account, fork the appropriate MoonRay repository, and clone the fork to create a repository on your local machine.
2. Edit, compile, and test your changes.
3. Commit your changes to a topic branch on your local repository, and push the branch to your fork.
4. Create a Pull Request on the appropriate MoonRay GitHub repository from your fork for your contribution.
5. Currently, no CI / Actions will be triggered, but we expect this to change as the project advances.
6. Pull Requests will be reviewed by project Contributors and Committers, who may discuss, offer constructive feedback, request changes, or approve the work.
7. Once approved by the required number of Committers, a Committer other than the contributor may merge the changes into the main branch.

Note that at this current early stage of MoonRay open source, all contributions will first round-trip through DWA's internal development and source management system. This ensures stability for our productions, and allows us to perform security scanning and regression testing before integrating any contributions from the open source community. Once reviewed, scanned, and tested, contributions will appear in a future release and the original Pull Request will be closed.

Please have patience as we continue to work on improving this process, with the goal of being able to directly accept contributions via Pull Requests with automatic and open scanning and testing soon.

## Coding Standards

Please see the [MoonRay Coding Standards documentation](https://docs.openmoonray.org/developer-reference/coding-standards/) for a reference on project code style and best practices.

## Testing Policy

Most MoonRay modules have a companion `tests` folder within the repository, containing a set of unit tests that validate its functionality. When contributing new code to MoonRay, make sure to include new or updated unit tests as appropriate to validate the expected behavior of the new code.

Additionally, MoonRay provides a [Render Acceptance Test Suite (RATS)](https://github.com/dreamworksanimation/rats) to catch visual regressions caused by changes to the codebase before those changes are deployed into a production environment. It works by comparing canonical images rendered with the previously sanctioned version of the renderer to images rendered with a development version.  

All contributions that may impact the resulting look of rendered images must pass RATS before being accepted. Unintentional look changes must be addressed in the contributed code. Intentional look changes must be approved by the TSC, and updated canonical reference images must be provided such that the tests continue to pass.
