# Deprecated Blueprint Transactions

[![Build Status](https://travis-ci.org/apiaryio/blueprint-transactions.png?branch=master)](https://travis-ci.org/apiaryio/blueprint-transactions)
[![Dependencies Status](https://david-dm.org/apiaryio/blueprint-transactions.png)](https://david-dm.org/apiaryio/blueprint-transactions)
[![devDependencies Status](https://david-dm.org/apiaryio/blueprint-transactions/dev-status.png)](https://david-dm.org/apiaryio/blueprint-transactions#info=devDependencies)
[![Coverage Status](https://coveralls.io/repos/github/apiaryio/blueprint-transactions/badge.svg?branch=master)](https://coveralls.io/github/apiaryio/blueprint-transactions?branch=master)


Blueprint Transactions library compiles *HTTP Transactions* (simple Request-Response pairs) from given API Blueprint AST.

> **Note:** To better understand *emphasized* terms in this documentation, please refer to the [Glossary of Terms][api-blueprint-glossary]. All data structures are described using the [MSON][mson-spec] format.


## Deprecation Notice

This project is superseded by the [Dredd Transactions][dredd-transactions] library.


## Features

* Inherits parameters from parent *Resource* and *Action* sections.
* Expands *URI Templates*.
* Warns on undefined placeholders in *URI Templates* (both query and path).
* Validates URI parameter types.
* Selects first *Request* and first *Response* if multiple are specified in the API Blueprint.


### Deprecated Features

* Compiles [Transaction Name][transaction-object-spec] string (vague identifier) for each *Transaction*.
* Provides [Transaction Origin][transaction-object-spec] with pointers to the API Blueprint AST.


## Installation

```
npm install blueprint-transactions
```


## Development

Blueprint Transactions library is written in [CoffeeScript](http://coffeescript.org/) language which compiles to JavaScript (ECMAScript 5).


## Usage

```javascript
var bt = require('blueprint-transactions');
var transactions = bt.compile(ast, './apiary.apib');
```


### `compile` (function)

Compiles *HTTP Transactions* from given API Blueprint AST.

```javascript
transactions = compile(ast, filename);
```

- `ast` (API Blueprint AST) - API Blueprint AST provided as a JavaScript object.
- `filename` (string) - Path to the API Blueprint file. *Soon to be deprecated!*
- `transactions` (array[Transaction]) - Compiled [Transaction objects][transaction-object-spec].


## Data Structures

### API Blueprint AST (object)

API Blueprint AST represents contents of an API Blueprint file in machine-readable way. For details refer to [API Blueprint AST specification][api-blueprint-ast-spec].

> **Note:** API Blueprint AST is deprecated and [API Elements][api-elements] should be used instead. That's why also Blueprint Transactions are deprecated in favor of [Dredd Transactions][dredd-transactions].


<a name="transaction-object"></a>
### Transaction (object)

Represents a single *HTTP Transaction* (Request-Response pair) and its location in the API Blueprint document. The location is provided in two forms:

- `name` - String representation, both human- and machine-readable.
- `origin` - Object of references to the original API Blueprint AST nodes.


### Properties

- request (object) - HTTP Request as described in API Blueprint
    - method
    - uri: `/message` (string) - Informative URI of the Request
    - headers (object)
    - body: `Hello world!\n` (string)
- response (object) - Expected HTTP Response as described in API Blueprint
    - status: `200` (string)
    - headers (object)
    - body (string)
    - schema (string)


### Deprecated Properties

- name: `Hello world! > Retrieve Message` (string) - Transaction Name, non-deterministic breadcrumb location of the HTTP Transaction within the API Blueprint document
- origin (object) - Object of references to the original API Blueprint AST nodes
    - filename: `./blueprint.md` (string)
    - apiName: `My Api` (string)
    - resourceGroupName: `Greetings` (string)
    - resourceName: `Hello, world!` (string)
    - actionName: `Retrieve Message` (string)
    - exampleName: `First example` (string)


[dredd]: https://github.com/apiaryio/dredd
[mson-spec]: https://github.com/apiaryio/mson
[api-elements]: http://api-elements.readthedocs.org/
[api-blueprint-glossary]: https://github.com/apiaryio/api-blueprint/blob/master/Glossary%20of%20Terms.md
[api-blueprint-ast-spec]: https://github.com/apiaryio/api-blueprint-ast
[dredd-transactions]: https://github.com/apiaryio/dredd-transactions/


[transaction-object-spec]: #transaction-object
