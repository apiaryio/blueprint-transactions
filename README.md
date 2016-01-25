# Blueprint Transactions

[![Build Status](https://travis-ci.org/apiaryio/blueprint-transactions.png?branch=master)](https://travis-ci.org/apiaryio/blueprint-transactions)
[![Dependencies Status](https://david-dm.org/apiaryio/blueprint-transactions.png)](https://david-dm.org/apiaryio/blueprint-transactions)
[![devDependencies Status](https://david-dm.org/apiaryio/blueprint-transactions/dev-status.png)](https://david-dm.org/apiaryio/blueprint-transactions#info=devDependencies)
[![Coverage Status](https://coveralls.io/repos/github/apiaryio/blueprint-transactions/badge.svg?branch=master)](https://coveralls.io/github/apiaryio/blueprint-transactions?branch=master)

[![NPM](https://nodei.co/npm/blueprint-transactions.png)](https://nodei.co/npm/blueprint-transactions/)


Blueprint Transactions library compiles *HTTP Transactions* (simple Request-Response pairs) from given API Blueprint AST.

> **Note:** To better understand *emphasized* terms in this documentation, please refer to the [Glossary of Terms][api-blueprint-glossary]. All data structures are described using the [MSON][mson-spec] format.


## Features

* Inherits parameters from parent *Resource* and *Action* sections.
* Expands *URI Templates*.
* Warns on undefined placeholders in *URI Templates* (both query and path).
* Validates URI parameter types.
* Selects first *Request* and first *Response* if multiple are specified in the API Blueprint.
* Compiles [Transaction Path][transaction-path-spec] (unique identifier) for each *Transaction*.
* Provides [Transaction Path Origin][transaction-object-spec] with pointers to the API Blueprint AST.


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

> **Note:** API Blueprint AST is deprecated and [API Description Namespace of Refract][refract-api-desc-ns] should be used instead. Blueprint Transactions will migrate to Refract in the future.


<a name="transaction-object"></a>
### Transaction (object)

Represents a single *HTTP Transaction* (Request-Response pair) and its location in the API Blueprint document. The location is provided in two forms:

- `path` - String representation, both human- and machine-readable.
- `pathOrigin` - Object of references to the original API Blueprint AST nodes.

> **Note:** They supersede `name` and `origin`, which are deprecated, because they don't provide deterministic location algorithm.


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
- path: `::Hello world!:Retreive Message::200 (application/json)` ([Transaction Path](#transaction-path))
- pathOrigin (object) - Object of references to the original API Blueprint AST nodes
    - apiName: `My Api` (string)
    - resourceGroupName: `Greetings` (string)
    - resourceName: `Hello, world!` (string)
    - actionName: `Retrieve Message` (string)
    - requestName: `Creating new greeting (application/json)` (string)
    - responseName: `400 (application/vnd.error+json)` (string)


### Deprecated Properties

- name: `Hello world! > Retrieve Message` (string) - Transaction Name, non-deterministic breadcrumb location of the HTTP Transaction within the API Blueprint document
- origin (object) - Object of references to the original API Blueprint AST nodes
    - filename: `./blueprint.md` (string)
    - apiName: `My Api` (string)
    - resourceGroupName: `Greetings` (string)
    - resourceName: `Hello, world!` (string)
    - actionName: `Retrieve Message` (string)
    - exampleName: `First example` (string)


<a name="transaction-path"></a>
## Transaction Path (string)

Canonical, deterministic way how to address a single *HTTP Transaction* (single Request-Response pair). It can serve as a unique identifier of the HTTP Transaction.

The Transaction Path string is a serialization of the `pathOrigin` object according to following rules:

- Colon `:` character as a delimiter.
- Colon character, which happens to be part of any component of the path, is escaped with backslash character `\`.
- No other characters than colon `:` are escaped.

### Components

- If certain component isn't available in the source data, it is present in both the `pathOrigin` object and the Transaction Path as an empty string.
- The `requestName` component is defined as name of the request followed by parentheses containing effective value of the `Content-Type` header. Any of those two parts can be omitted. If both parts are present, they're separated by a single space ` ` character.
- The `responseName` component is defined as HTTP code of the response followed by parentheses containing effective value of the `Content-Type` header. Any of those two parts can be omitted. If both parts are present, they're separated by a single space ` ` character.


## Examples


### Full Notation with Multiple Request-Response Pairs

```markdown
# Sample API Name

## Group Sample Group Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Request (application/json)
+ Response 200 (application/json)

+ Request (application/xml)
+ Response 200 (application/xml)
```


**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "Sample Group Name",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "(application/xml)",
  "responseName": "200 (application/xml)",
}
```


**Transaction Path:**

```
Sample API Name:Sample Group Name:Sample Resource Name:Sample Action Name:(application/xml):200 (application/xml)
```


### Full Notation with Implicit Request

```markdown
# Sample API Name

## Group Sample Group Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Response 200
```


**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "Sample Group Name",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "",
  "responseName": "200",
}
```


**Transaction Path:**

```
Sample API Name:Sample Group Name:Sample Resource Name:Sample Action Name::200
```


### Full Notation with Multiple Requests within One Transaction Example

```markdown
# Sample API Name

## Group Sample Group Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Response 200 (text/plain)

+ Request Sample Request Name (application/json)
+ Request Another Sample Request Name (application/json)
+ Request (application/json)
+ Response 200 (application/json)
+ Response 401 (application/json)
```


**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "Sample Group Name",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "Another Sample Request Name (application/json)",
  "responseName": "401 (application/json)",
}
```


**Transaction Path:**

```
Sample API Name:Sample Group Name:Sample Resource Name:Sample Action Name:Another Sample Request Name (application/json):401 (application/json)
```


### Full Notation with Multiple Requests Each Having Multiple Responses

```markdown
# Sample API Name

## Group Sample Group Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Response 200 (application/json)
+ Response 401 (application/json)
+ Response 500 (application/json)

+ Request (application/xml)
+ Response 200 (application/xml)
+ Response 500 (application/xml)
```


**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "Sample Group Name",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "",
  "responseName": "401 (application/json)",
}
```


**Transaction Path:**

```
Sample API Name:Sample Group Name:Sample Resource Name:Sample Action Name::200 (application/json)
```


### Full Notation with Resolution of the Effective Content-Type Value

```markdown
# Sample API Name

## Group Sample Group Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Request
    + Headers

            X-Request-ID: 30f14c6c1fc85cba12bfd093aa8f90e3
            Content-Type: application/hal+json

+ Response 200
```


**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "Sample Group Name",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "(application/hal+json)",
  "responseName": "200",
}
```


**Transaction Path:**

```
Sample API Name:Sample Group Name:Sample Resource Name:Sample Action Name::200 (application/json)
```


### Full Notation without Group

```markdown
# Sample API Name

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Request (application/json)
+ Response 200 (application/json)
```

**Transaction Path Origin:**

```json
{
  "apiName": "Sample API Name",
  "resourceGroupName": "",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "(application/json)",
  "responseName": "200 (application/json)"
}
```


**Transaction Path:**

```
Sample API Name::Sample Resource Name:Sample Action Name:(application/json):200 (application/json)
```


### Full Notation without Group and API Name

```markdown
### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Request (application/json)
+ Response 200 (application/json)
```


**Transaction Path Origin:**

```json
{
  "apiName": "",
  "resourceGroupName": "",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "(application/json)",
  "responseName": "200 (application/json)"
}
```

**Transaction Path:**

```
::Sample Resource Name:Sample Action Name:(application/json):200 (application/json)
```


### Full Notation without Group and with API Name Containing a Colon

```markdown
# My API: Revamp

### Sample Resource Name [/resource]

#### Sample Action Name [POST]

+ Request (application/json)
+ Response 200 (application/json)
```


**Transaction Path Origin:**

```json
{
  "apiName": "My API: Revamp",
  "resourceGroupName": "",
  "resourceName": "Sample Resource Name",
  "actionName": "Sample Action Name",
  "requestName": "(application/json)",
  "responseName": "200 (application/json)"
}
```

**Transaction Path:**

```
My API\: Revamp::Sample Resource Name:Sample Action Name:(application/json):200 (application/json)
```


### Simplified Notation

```markdown
# GET /message
+ Response 200 (text/plain)

      Hello World
```


**Transaction Path Origin:**

```json
{
  "apiName": "",
  "resourceGroupName": "",
  "resourceName": "/message",
  "actionName": "GET",
  "requestName": "",
  "responseName": "200 (text/plain)"
}
```


**Transaction Path:**

```
::/message:GET::200 (text/plain)
```


[dredd]: https://github.com/apiaryio/dredd
[mson-spec]: https://github.com/apiaryio/mson
[api-blueprint]: https://apiblueprint.org/
[api-blueprint-spec]: https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md
[api-blueprint-glossary]: https://github.com/apiaryio/api-blueprint/blob/master/Glossary%20of%20Terms.md
[api-blueprint-ast-spec]: https://github.com/apiaryio/api-blueprint-ast
[refract-api-desc-ns]: https://github.com/refractproject/refract-spec/blob/master/namespaces/api-description-namespace.md

[transaction-path-spec]: #transaction-path
[transaction-object-spec]: #transaction-object
