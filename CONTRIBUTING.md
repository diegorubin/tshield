# Contributing to Tshield

First of all, thanks for taking time to contribuite!

The following is a set of guidelines for contributing to Tshield. Feel free to propose changes to this document in a pull request.

####Table of Contents:

* [Code of Conduct](#code-of-conduct)

* [Submit Enhancement Suggestion](#submit-enhancement-suggestion)
 
* [Local Development](#local-development)
 
* [Pull Requests](#pull-requests)
 
* [Styleguides](#styleguides)

## Code of Conduct
This project and everyone participating in it is governed by the [project Code of Conduct](CODE_OF_CONDUCT.md).

## Submit Enhancement Suggestion

Enhancement suggestions are tracked as [GitHub issues](https://guides.github.com/features/issues/). So, if you want to suggest an enhancement create an issue on this repository, following the below instructions

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most Tshield users.
* **List some other API mocks or applications where this enhancement exists.**
* **Specify which version of Tshield you're using.**
* **Specify the name and version of the OS you're using.**

## Local development

First install dependencies.
_We recommend use of the RVM to manage project dependencies._

```
bundle install
```

**Run server to development**

To start server execute:

`rake server`

**Build**

To generate ruby gem execute:

`rake build`

**Test**

To run all unit tests:

`rake spec`

To run all component tests:

`rake component_tests`

## Pull Requests

The process described here has several goals:

- Maintain Tshield quality
- Fix problems that are important to users
- Add improvements or new features

Please follow these steps to have your contribution considered by the maintainers:

1. Follow the [styleguides](#styleguides)
2. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing <details><summary>What if the status checks are failing?</summary>If a status check is failing, and you believe that the failure is unrelated to your change, please leave a comment on the pull request explaining why you believe the failure is unrelated. A maintainer will re-run the status check for you. If we conclude that the failure was a false positive, then we will open an issue to track that problem with our status check suite.</details>
3. Do not decrease tests coverage
4. Create automated behavior tests (component_tests)

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

## Styleguides
[TBD]

## Basic sample for componente/integration test
**[WIP]**
