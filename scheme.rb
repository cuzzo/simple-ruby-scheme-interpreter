#! /usr/bin/env ruby

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
  lambda { |*args| args.reduce(symbol) }
end

$global_env = {
  "+" => op(:+),
  "-" => op(:-),
  "*" => op(:*),
  "/" => op(:/),
  ">" => op(:>),
  "<" => op(:<),
  ">=" => op(:>=),
  "<=" => op(:<=),
  "abs" => op(:abs),
  "modulo" => op(:%),
  "remainder" => op(:rem),
  "=" => op(:==),
  "equal?" => op(:==),
  "eq?" => op(:==), # TODO: not quite, identity...
  "not" => op(:!=),
  "expt" => lambda { |a, b=Math::E| a**b },
  "sqrt" => lambda { |a| Math.sqrt(a) },
  "log" => lambda { |a| Math.log(a) },
  "floor" => lambda { |a| Math.floor(a) },
  "ceiling" => lambda { |a| Math.ceil(a) },
  "round" => lambda { |a| Math.round(a) },
  # trig: sin, cosh, atan...
  # quotient, numerator, denominator, gcd, lcm, truncate, rationalize
  "min" => lambda { |*args| args.min },
  "max" => lambda { |*args| args.max },
  "length" => lambda { |args| args.length },
  "list" => lambda { |*args| args },
  "list?" => lambda { |a| a.is_a?(Array) },
  "null?" => lambda { |a| a == [] },
  "number?" => lambda { |a| a.is_a?(Integer) || a.is_a?(Float) },
  "symbol?" => lambda { |a| a.is_a?(String) },
  "procedure?" => lambda { |a| a.respond_to?(:call) },
  "display" => lambda { |a| puts a },
  "apply" => lambda { |proc, args| proc.call(*args) },
  "begin" => lambda { |*args| args.last },
  "car" => lambda { |a| a.first },
  "cdr" => lambda { |a| a[1..-1] },
  "cons" => lambda { |a, b| [a] + b }
  # map
}

# Allow true & false to respond to interger operations like +, *, >, etc.
class FalseClass
  def to_i; 0 end
  def method_missing(m, *args, &block)
    to_i.send(m, *args, &block)
  end
end

class TrueClass
  def to_i; 1 end
  def method_missing(m, *args, &block)
    to_i.send(m, *args, &block)
  end
end


def parse(str)
  read_from_tokens(tokenize(str))
end

def tokenize(str)
  str.gsub('(', ' ( ').gsub(')', ' ) ').split(" ")
end

def read_from_tokens(tokens)
  if tokens.length == 0
    raise SyntaxError("Unexpected EOF while reading")
  end
  token = tokens.shift()
  if token == '('
    sub_tokens = []
    while tokens[0] != ')'
      sub_tokens.append(read_from_tokens(tokens))
    end
    tokens.shift() # pop off ')'
    return sub_tokens
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
      String(token)
    end
  end
end

def scheme_eval(x, env=$global_env)
  if x.is_a?(String)
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
  else
    proc = scheme_eval(x.first, env)
    args = x[1..-1].map { |exp| scheme_eval(exp, env) }
    proc.call(*args)
  end
end
