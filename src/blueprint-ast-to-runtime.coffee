clone = require 'clone'
inheritParameters = require './inherit-parameters'
expandUriTemplateWithParameters = require './expand-uri-template-with-parameters'
exampleToHttpPayloadPair = require './example-to-http-payload-pair'
convertAstMetadata = require './convert-ast-metadata'
validateParameters = require './validate-parameters'

isEmptyString = (string) ->
  string == '' or string == null

getExampleName = (example, exampleIndex) ->
  name = 'Example ' + (exampleIndex + 1)
  if isEmptyString(example.name)
    if example.requests.length > 0
      reqName = example.requests[0].name
      if !isEmptyString(reqName)
        name = reqName
    else
      # Names can have empty example
      name = ''

  name

getExamplePath = (example, exampleIndex) ->
  name = 'Example ' + (exampleIndex + 1)
  if isEmptyString(example.name)
    if example.requests.length > 0
      reqName = example.requests[0].name
      if !isEmptyString(reqName)
        name = reqName
    else
      # Path can't have empty example
      name = 'Example 1'

  name

blueprintAstToRuntime = (blueprintAst, filename) ->
  runtime =
    transactions: []
    errors: []
    warnings: []

  # path origin is predictible, consistent transaction paths (ids)
  pathOrigin = {}

  # TO BE DEPRECATED
  # origin is old logic used for generating transaction names (> delimited)
  # this is supposed to be eradicated and this logic will be moved to the
  origin = {}

  # TO BE DEPRECATED: filename
  # filename is used only for compiling to human readeable name in reporters
  # and this logic will be moved to Dredd reporters
  origin['filename'] = filename

  if blueprintAst['name'] != ""
    origin['apiName'] = blueprintAst['name']
  else
    origin['apiName'] = origin['filename']

  pathOrigin['apiName'] = blueprintAst['name']


  for resourceGroup, index in blueprintAst['resourceGroups']
    #should not be possible specify more than one unnamed group, must verify
    # if resourceGroup['name'] != ""
    #   origin['resourceGroupName'] = resourceGroup['name']
    # else
    #   origin['resourceGroupName'] = "Group #{index + 1}"

    pathOrigin['resourceGroupName'] = resourceGroup['name']

    origin['resourceGroupName'] = resourceGroup['name']

    for resource in resourceGroup['resources']

      if resource['name'] != ""
        pathOrigin['resourceName'] = resource['name']
        origin['resourceName'] = resource['name']
      else
        pathOrigin['resourceName'] = resource['uriTemplate']
        origin['resourceName'] = resource['uriTemplate']


      # TO BE DEPRECATED
      # Remove this! It has nothing to do in origin!!!!
      # Get rid with polluting of origin with not related data!
      # Put this through deprecation process, some users are already programming against it.
      origin['uriTemplate'] = "#{resource['uriTemplate']}"

      for action in resource['actions']
        if action['name'] != ""
          pathOrigin['actionName'] = action['name']
          origin['actionName'] = action['name']
        else
          pathOrigin['actionName'] = action['method']
          origin['actionName'] = action['method']

        actionParameters = convertAstMetadata action['parameters']
        resourceParameters = convertAstMetadata resource['parameters']

        parameters = inheritParameters actionParameters, resourceParameters

        # validate URI parameters
        paramsResult = validateParameters parameters

        for message in paramsResult['errors']
          runtime['errors'].push {
            origin: clone origin
            message: message
          }

        # expand URI parameters
        if action.attributes?.uriTemplate
          uri = action.attributes.uriTemplate
        else
          uri = resource['uriTemplate']

        uriResult = expandUriTemplateWithParameters uri, parameters

        for message in uriResult['warnings']
          runtime['warnings'].push {
            origin: clone origin
            message: message
          }

        for message in uriResult['errors']
          runtime['errors'].push {
            origin: clone origin
            message: message
          }


        if uriResult['uri'] != null
          for example, exampleIndex in action['examples']

            origin['exampleName'] = getExampleName example, exampleIndex

            # Paths can't have empty example
            pathOrigin['exampleName'] = getExamplePath example, exampleIndex

            result = exampleToHttpPayloadPair example

            for message in result['warnings']
              runtime['warnings'].push {
                origin: clone origin
                message: message
              }

            # Errors in pair selecting should not happen
            # for message in result['errors']
            #   runtime['errors'].push {
            #     origin: JSON.parse(JSON.stringify(origin))
            #     message: message
            #   }

            transaction = result['pair']

            transaction['origin'] = clone origin
            transaction['pathOrigin'] = clone pathOrigin

            transaction['request']['uri'] = uriResult['uri']
            transaction['request']['method'] = action['method']

            runtime['transactions'].push transaction

  return runtime

module.exports = blueprintAstToRuntime
