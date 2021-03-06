#! /usr/bin/env ruby

# Type system
module S_Number; end
class Integer; include S_Number end
class Float; include S_Number end
# Symbol
class S_String < String; end
class S_List < Array; end # Not yet in use
module S_Boolean; end
class FalseClass; include S_Boolean end
class TrueClass; include S_Boolean end


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


# Implement standard lib
def op(symbol)
  ->(*args) { args.reduce(symbol) }
end

def op_default(symbol, d)
  ->(*args) { args.reduce(symbol) || d }
end

def divide(args)
  args = [1] + args if args.length == 1
  args.map(&:to_f).reduce(:/)
end

MATH_BUILTINS = [:acos, :acosh, :asin, :asinh, :atan2, :atanh, :cos, :cosh, :log, :log10, :log2, :sin, :sinh, :sqrt, :tan, :tanh]
  .map do |func|
    [func, lambda { |a| Math.send(func, a) } ]
  end

$global_env = Hash[MATH_BUILTINS].merge({
  :+ => op_default(:+, 0),
  :- => op(:-),
  :* => op_default(:*, 1),
  :/ => ->(*args) { divide(args) },
  :> => op(:>),
  :< => op(:<),
  :>= => op(:>=),
  :<= => op(:<=),
  :abs => op(:abs),
  :modulo => op(:%),
  :remainder => ->(a, b) { a.remainder(b) },
  :quotient => op(:/),
  "=".to_sym => op(:==),
  :equal? => op(:==),
  :eqv? => ->(a, b) { a.eql?(b) },
  :eq? => ->(a, b) { a.equal?(b) },
  :not => ->(a) { !a },
  :expt => op(:**),
  :trunc => ->(a, b) { a.truncate(b) },
  :min => ->(*args) { args.min },
  :max => ->(*args) { args.max },
  :length => ->(a) { a.length },
  :list => ->(*args) { Array.new(args) },
  :list? => ->(a) { a.is_a?(Array) },
  :pair? => ->(a) { a.is_a?(Array) && !a.empty? },
  :null? => ->(a) { a == [] },
  :boolean? => ->(a) { a.is_a?(S_Boolean) },
  :integer? => ->(a) { a.is_a?(Integer) },
  :number? => ->(a) { a.is_a?(S_Number) },
  :string? => ->(a) { a.is_a?(S_String) },
  :symbol? => ->(a) { a.is_a?(Symbol) },
  :procedure? => ->(a) { a.respond_to?(:call) },
  :even? => ->(a) { a.even? },
  :odd? => ->(a) { a.odd? },
  :positive? => ->(a) { a > 0 },
  :negative? => ->(a) { a < 0 },
  :zero? => ->(a) { a.zero? },
  :display => ->(a) { print(a); a },
  :apply => ->(proc, args) { proc.call(*args) },
  :append => op(:+),
  :begin => ->(*args) { args.last },
  :car => ->(a) { a.first },
  :cdr => ->(a) { a[1..-1] },
  :cons => ->(a, b) { b.is_a?(Array) ? [a] + b : [a] + [b] }, # TODO: should return pair?
  :error => ->(a) { raise a },

  # HIGHER-ORDER FUNCTIONS
  :map => ->(a, b) { b.map { |item| a.call(item) } },
  :filter => ->(a, b) { b.filter { |item| a.call(item) } },
  :reduce => ->(a, b, c) { b.reduce(c) { |acc, item| a.call(item) } },
  # cond, promise?, set-car!, set-cdr!
})


# Scheme interpreter
def parse(str)
  read_from_tokens(tokenize(str))
end

def tokenize(str)
  str
    .gsub(/\;[^"]*\n/, '')
    .gsub(/\n/, '')
    .split(/([; ()"])/)
    .reject(&:empty?)
end

def read_from_tokens(tokens)
  if tokens.length == 0
    raise SyntaxError("Unexpected EOF while reading")
  end

  # Ignore spaces
  token = tokens.shift()
  while token == ' '
    token = tokens.shift()
  end

  if token == '('
    sub_tokens = []
    while tokens.first != ')'
      sub_tokens.append(read_from_tokens(tokens))
    end
    tokens.shift() # pop off ')'
    return sub_tokens
  elsif token == "'"
    [:quote, read_from_tokens(tokens)]
  elsif token[0] == "'"
    [:quote, atom(token[1..-1])]
  elsif token == '"'
    sub_tokens = []
    while tokens.first != '"'
      sub_tokens << tokens.shift()
    end
    tokens.shift() # pop off '"'
    return S_String.new(sub_tokens.join(""))
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
        token.to_sym
      end
    end
  end
end

def scheme_eval(x, env=$global_env)
  if x.is_a?(Symbol)
    return env[x]
  elsif not x.is_a?(Array)
    return x
  elsif x[0] == :quote
    (_, exp) = x
    return exp
  elsif x[0] == :if
    (_, test, conseq, alt) = x
    exp = scheme_eval(test, env) ? conseq : alt
    return scheme_eval(exp, env)
  elsif x[0] == :define
    (_, rb_var, exp) = x
    env[rb_var.to_sym] = scheme_eval(exp, env)
  elsif x[0] == :lambda
    (_, params, body) = x
    return Procedure.new(params, body, env)
  elsif x[0] == :exit
    exit
  else
    proc = scheme_eval(x[0], env)
    args = x[1..-1].map { |exp| scheme_eval(exp, env) }
    proc.call(*args)
  end
end
