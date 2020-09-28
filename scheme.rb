#! /usr/bin/env ruby

# Type system
module S_Number; end
class Integer; include S_Number end
class Float; include S_Number end
class S_Symbol < String; end
class S_String < String; end
class S_List < Array; end

# Allow true & false to respond to interger operations like +, *, >, etc.
module S_Boolean
  def method_missing(m, *args, &block)
  #  to_i.send(m, *args, &block)
  end
end

class FalseClass
  include S_Boolean
  #def to_i; 0 end
end

class TrueClass
  include S_Boolean
  #def to_i; 1 end
end


# Class to create Scheme functions (procedures)
class Procedure
  def initialize(params, body, env)
    @params, @body, @env = params, body, env
  end

  def call(*args)
    env = @env.merge(Hash[@params.zip(args)]) # params & args override env
    scheme_eval(@body, env)
  end
end

def op(symbol)
  ->(*args) { args.reduce(symbol) }
end

MATH_BUILTINS = ["acos", "acosh", "asin", "asinh", "atan2", "atanh", "cos", "cosh", "log", "log10", "log2", "sin", "sinh", "sqrt", "tan", "tanh"]
  .map do |func|
    [func, lambda { |a| Math.send(func.to_sym, a) } ]
  end

$global_env = Hash[MATH_BUILTINS].merge({
  "+" => op(:+),
  "-" => op(:-),
  "*" => op(:*),
  "/" => ->(*args) { args.map(&:to_f).reduce(:/) },
  ">" => op(:>),
  "<" => op(:<),
  ">=" => op(:>=),
  "<=" => op(:<=),
  "abs" => op(:abs),
  "modulo" => op(:%),
  "remainder" => ->(a, b) { a.remainder(b) },
  "quotient" => op(:/),
  "=" => op(:==),
  "equal?" => op(:==),
  "eq?" => ->(a, b) { a.equal?(b) },
  "not" => op(:!=),
  "expt" => op(:**),
  "trunc" => ->(a, b) { a.truncate(b) },
  "min" => ->(*args) { args.min },
  "max" => ->(*args) { args.max },
  "length" => ->(a) { a.length },
  "list" => ->(*args) { S_List.new(args) },
  "list?" => ->(a) { a.is_a?(S_List) },
  "pair?" => ->(a) { a.is_a?(S_List) && !a.empty? },
  "null?" => ->(a) { a == [] },
  "boolean?" => ->(a) { a.is_a?(S_Boolean) },
  "integer?" => ->(a) { a.is_a?(Integer) },
  "number?" => ->(a) { a.is_a?(S_Number) },
  "string?" => ->(a) { a.is_a?(S_String) },
  "symbol?" => ->(a) { a.is_a?(S_Symbol) },
  "procedure?" => ->(a) { a.respond_to?(:call) },
  "even?" => ->(a) { a.even? },
  "odd?" => ->(a) { a.odd? },
  "zero?" => ->(a) { a.zero? },
  "display" => ->(a) { print(a) },
  "apply" => ->(proc, args) { proc.call(*args) },
  "append" => op(:+),
  "begin" => ->(*args) { args.last },
  "car" => ->(a) { a.first },
  "cdr" => ->(a) { a[1..-1] },
  "cons" => ->(a, b) { [a] + b }, # TODO: should return pair?
  "error" => ->(a) { raise a },

  # HIGHER-ORDER FUNCTIONS
  "map" => ->(a, b) { b.map { |item| a.call(item) } },
  "filter" => ->(a, b) { b.filter { |item| a.call(item) } },
  "reduce" => ->(a, b, c) { b.reduce(c) { |acc, item| a.call(item) } },
  # cond, promise?, set-car!, set-cdr!
})


def parse(str)
  read_from_tokens(tokenize(str))
end

def tokenize(str)
  str
    .gsub('(', ' ( ')
    .gsub(')', ' ) ')
    .gsub('"', ' " ')
    .split(' ')
end

def read_from_tokens(tokens)
  if tokens.length == 0
    raise SyntaxError("Unexpected EOF while reading")
  end
  token = tokens.shift()
  if token == '('
    sub_tokens = []
    while tokens.first != ')'
      sub_tokens.append(read_from_tokens(tokens))
    end
    tokens.shift() # pop off ')'
    return sub_tokens
  elsif token == '"'
    sub_tokens = []
    while tokens.first != '"'
      sub_tokens << tokens.shift()
    end
    tokens.shift() # pop off '"'
    return S_String.new(sub_tokens.join(" "))
  elsif token == ')'
    raise SyntaxError("Unexpected )")
  else
    return atom(token)
  end
end

def atom(token)
  begin
    Integer(token)
  rescue
    begin
      Float(token)
    rescue
      if token == "#t"
        true
      elsif token == "#f"
        false
      else
        S_Symbol.new(token)
      end
    end
  end
end

def scheme_eval(x, env=$global_env)
  if x.is_a?(S_Symbol)
    return env[x]
  elsif not x.is_a?(Array)
    return x
  elsif x[0] == "quote"
    (_, exp) = x
    return exp
  elsif x[0] == "if"
    (_, test, conseq, alt) = x
    exp = scheme_eval(test, env) ? conseq : alt
    return scheme_eval(exp, env)
  elsif x[0] == "define"
    (_, rb_var, exp) = x
    env[rb_var] = scheme_eval(exp, env)
  elsif x[0] == "lambda"
    (_, params, body) = x
    return Procedure.new(params, body, env)
  elsif x[0] == "exit"
    exit
  else
    proc = scheme_eval(x.first, env)
    args = x[1..-1].map { |exp| scheme_eval(exp, env) }
    proc.call(*args)
  end
end
