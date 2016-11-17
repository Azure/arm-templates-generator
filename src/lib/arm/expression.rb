require_relative 'module_definition'

# noinspection ALL
module Azure::ARM

  module PredefinedExpressions

    def add(x,y)
      CallExpression.new 'add', x, y
    end

    def sub(x,y)
      CallExpression.new 'sub', x, y
    end

    def mul(x,y)
      CallExpression.new 'mul', x, y
    end

    def div(x,y)
      CallExpression.new 'div', x, y
    end

    def mod(x,y)
      CallExpression.new 'mod', x, y
    end

    def length(x)
      CallExpression.new 'length', x
    end

    def int(valueToConvert)
      CallExpression.new 'int', valueToConvert
    end

    def resourceGroup
      CallExpression.new 'resourceGroup'
    end

    def resourceId(*args)
      CallExpression.new 'resourceId', *args
    end

    def concat(*args)
      CallExpression.new 'concat', *args
    end

    def copyIndex
      CallExpression.new 'copyIndex'
    end

    def deployment
      CallExpression.new 'deployment'
    end

    def subscription
      CallExpression.new 'subscription'
    end

    def parameters(parameterName)
      CallExpression.new 'parameters', parameterName
    end

    def variables(variableName)
      CallExpression.new 'variables', variableName
    end

    def listKeys(resourceName, apiVersion)
      CallExpression.new 'listKeys', resourceName, apiVersion
    end

    def providers(providerNamespace, resourceType=nil)
      CallExpression.new 'providers', providerNamespace, resourceType
    end

    def reference(resourceName, apiVersion=nil)
      CallExpression.new 'reference', resourceName, apiVersion
    end

    def base64(x)
      CallExpression.new 'base64', x
    end

    def padLeft(stringToPad, totalLength, paddingCharacter)
      CallExpression.new 'padLeft', stringToPad, totalLength, paddingCharacter
    end

    def replace(originalString, oldCharacter, newCharacter)
      CallExpression.new 'replace', originalString, oldCharacter, newCharacter
    end

    def split(inputString, delimiter)
      CallExpression.new 'split', inputString, delimiter
    end

    def string(valueToConvert)
      CallExpression.new 'string', valueToConvert
    end

    def substring(stringToParse, startIndex, length)
      CallExpression.new 'substring', stringToParse, startIndex, length
    end

    def toLower(stringToChange)
      CallExpression.new 'toLower', stringToChange
    end

    def toUpper(stringToChange)
      CallExpression.new 'toUpper', stringToChange
    end

    def trim(stringToTrim)
      CallExpression.new 'trim', stringToTrim
    end

    def uniqueString(stringForCreatingUniqueString, *args)
      CallExpression.new 'uniqueString', stringForCreatingUniqueString, *args
    end

    def uri(baseUri, relativeUri)
      CallExpression.new 'uri', baseUri, relativeUri
    end

  end

  private

  class Expression

    def to_ary
      [self.to_s]
    end

    def internal_s
      ''
    end

    def to_s
      '[' + internal_s + ']'
    end

    def method_missing(key, *args)
      if !args.nil? && args.length > 0
        CallExpression.new key.to_s, *args
      else
        NameExpression.new key.to_s
      end
    end

  end

  class IntLiteral < Expression

    def initialize(value)
      @value = value
    end

    def to_s
      internal_s
    end

    def internal_s
      @value.to_s
    end

  end

  class StringLiteral < Expression

    def initialize(value)
      @value = value
    end

    def internal_s
      "'" + @value + "'"
    end

  end

  class CallExpression < Expression

    def initialize(func, *args)
      @method = func
      @args = []
      args.each do |arg|
        if arg.is_a? String
          @args.push StringLiteral.new arg
        end
        if arg.is_a? Numeric
          @args.push IntLiteral.new arg
        end
        if arg.is_a? Expression
          @args.push arg
        end
      end
    end


    def method_missing(key, *args)
      expr = DotExpression.new self, key

      if !args.nil? && args.length > 0
        expr = CallExpression.new expr, *args
      end

      expr
    end

    def internal_s
      result = @method + '('

      first = true
      @args.each do |arg|
        result += ',' unless first
        first = false
        result += arg.internal_s
      end

      result + ')'
    end

  end

  class NameExpression < Expression

    def initialize(name)
      @name = name
    end

    def method_missing(key, *args)
      expr = DotExpression.new self, key

      if !args.nil? && args.length > 0
        expr = CallExpression.new expr, *args
      end

      expr
    end

    def internal_s
      @name
    end

  end

  class DotExpression < Expression

    def initialize(prefix, suffix)
      @prefix = prefix
      @suffix = suffix.to_s
    end

    def method_missing(key, *args)
      expr = DotExpression.new self, key

      if !args.nil? && args.length > 0
        expr = CallExpression.new expr, *args
      end

      expr
    end

    def internal_s
      @prefix.internal_s + '.' + @suffix
    end
  end

end