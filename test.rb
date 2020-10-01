require_relative "scheme"

$orig_env = $global_environment.dup
describe "scheme" do
  before(:each) do
    $global_environment = $orig_env.dup
  end

  before(:all) do
    @orig_stdout = $stdout
    #$stdout = File.open("/dev/null", "r+")
  end

  after(:all) do
    $stdout = @orig_stdout
  end

  subject { scheme_eval(parse(program)) }

  context "arithmetic" do
    context "addition" do
      context "integers" do
        let(:program) { "(+ 1   2)" }
        it { is_expected.to eq(3) }
      end

      context "mixed numbers" do
        let(:program) { "(+ 1.5 2 -8)" }
        it { is_expected.to eq(-4.5) }
      end

      context "four numbers" do
        let(:program) { "(+ 1 2 3 4)" }
        it { is_expected.to eq(10) }
      end

      context "no args" do
        let(:program) { "(+)" }
        it { is_expected.to eq(0) }
      end
    end

    context "subtraction" do
    end

    context "multiplication" do
      context "floats and ints" do
        let(:program) { "(* 2.5 2)" }
        it { is_expected.to eq(5.0) }
      end

      context "four numbers" do
        let(:program) { "(* 1 2 3 4)" }
        it { is_expected.to eq(24) }
      end

      context "one arg" do
        let(:program) { "(* 1)" }
        it { is_expected.to eq(1) }
      end

      context "no args" do
        let(:program) { "(*)" }
        it { is_expected.to eq(1) }
      end
    end

    context "expt" do
      let(:program) { "(expt 2 8)" }
      it { is_expected.to eq(256) }
    end

    context "division" do
      context "/" do
        let(:program) { "(/ 5  2)" }
        it { is_expected.to eq(2.5) }
      end

      context "1 arg" do
        let(:program) { "(/ 3)" }
        it { is_expected.to eq(1.0/3) }
      end

      context "quotient" do
        let(:program) { "(quotient 5 2)" }
        it { is_expected.to eq(2) }
      end

      context "remainders" do
        context  "modulo" do
          context "positive numbers" do
            let(:program) { "(modulo 7 3)" }
            it { is_expected.to eq(1) }
          end

          context "negative numbers" do
            let(:program) { "(modulo -7 3)" }
            it { is_expected.to eq(2) }
          end
        end

        context  "remainder" do
          context "positive numbers" do
            let(:program) { "(remainder 7 3)" }
            it { is_expected.to eq(1) }
          end

          context "negative numbers" do
            let(:program) { "(remainder -7 3)" }
            it { is_expected.to eq(-1) }
          end
        end
      end
    end
  end

  context "basic operators" do
    context "negation" do
      let(:program) { "(not #{value_to_negate})" }
      context "true" do
        let(:value_to_negate) { "#t" }
        it { is_expected.to eq(false) }
      end

      context "true" do
        let(:value_to_negate) { "#f" }
        it { is_expected.to eq(true) }
      end

      context "integer" do
        let(:value_to_negate) { "3" }
        it { is_expected.to eq(false) }
      end

      context "list" do
        let(:value_to_negate) { "(list 3)" }
        it { is_expected.to eq(false) }
      end

      context "empty list" do
        let(:value_to_negate) { "'()" }
        it { is_expected.to eq(false) }
      end

      context  "symbol" do
        let(:value_to_negate) { "'nil" }
        it { is_expected.to eq(false) }
      end
    end

    context "boolean?" do
      let(:program) { "(boolean? #{value_to_test})" }
      context "boolean" do
        let(:value_to_test) { "#f" }
        it { is_expected.to eq(true) }
      end

      context "0" do
        let(:value_to_test) { "0" }
        it { is_expected.to eq(false) }
      end

      context "empty list" do
        let(:value_to_test) { "'()" }
        it { is_expected.to eq(false) }
      end
    end

    context "eqv?" do
      context "same symbols" do
        let(:program) { "(eqv? 'a 'a)" }
        it { is_expected.to eq(true) }
      end

      context "same type, different values" do
        let(:program) { "(eqv? 'a 'b)" }
        it { is_expected.to eq(false) }
      end

      context "same integers" do
        let(:program) { "(eqv? 2 2)" }
        it { is_expected.to eq(true) }
      end

      context "same long integers" do
        let(:program)  { "(eqv? 100000000 100000000)" }
        it { is_expected.to eq(true) }
      end

      context "pairs" do # not really implmeented...
        let(:program) { "(eqv? (cons 1 2) (cons 1 2))" }
        it { is_expected.to eq(true) }
      end

      context "lambdas" do
        let(:program) { "(eqv? (lambda () 1) (lambda () 2))" }
        it { is_expected.to eq(false)  }
      end

      context "falls and symbol" do
        let(:program) { "(eqv? #f 'nil)" }
        it { is_expected.to eq(false) }
      end

      context "same variable" do
        let(:program) do
          """(begin
            (define p (lambda () 1))
            (eqv? p p))"""
        end
        it { is_expected.to eq(true) }
      end

      context "two lists, same values" do
        let(:program) { "(eqv? '(a) '(a))" }
        it { is_expected.to eq(true) }
      end

      context "two different strings, same chars" do
        let(:program) { "(eqv? \"a\" \"a\")" }
        it { is_expected.to eq(true) }
      end

      context "two lists, one returned by cdr" do
        let(:program) { "(eqv? '(b) (cdr '(a b)))" }
        it { is_expected.to eq(true) }
      end
    end

    context "equality" do
      context ".eq?" do
        context "different types" do
          let(:program) { "(eq? 5 5.0)" }
          it { is_expected.to eq(false) }
        end

        context "same types" do
          let(:program) { "(eq? 5.0 5.0)" }
          it { is_expected.to eq(true) }
        end

        context "different lists, same values" do
          let(:program) { "(eq? (quote (1 2 3)) (quote (1 2 3)))" }
          it { is_expected.to eq(false) }
        end

        context "same list" do
          let(:program) do
            """(begin
                 (define x (quote (1 2 3)))
                 (eq? x x))"""
          end
          it { is_expected.to eq(true) }
        end

        context "same symbols" do
          let(:program) { "(eq? 'a 'a)" }
          it { is_expected.to eq(true) }
        end

        context "two strings with same chars" do
          let(:program) { "(eq? \"a\" \"a\")" }
          it { is_expected.to eq(false) }
        end

        context "two empty strings" do
          let(:program) { "(eq? \"\" \"\")" }
          it { is_expected.to eq(false) }
        end

        context "two same built-ins" do
          let(:program) { "(eq? car car)" }
          it { is_expected.to eq(true) }
        end
      end

      context "=" do
        context "different types" do
          let(:program) { "(= 5 5.0)" }
          it { is_expected.to eq(true) }
        end

        context "same types" do
          let(:program) { "(= 5 5)" }
          it { is_expected.to eq(true) }
        end

        context "different values" do
          let(:program) { "(= 5 6)" }
          it { is_expected.to eq(false) }
        end
      end

      context "equal?" do
        let(:program) { '(equal? "test string" "test string")' }
        it { is_expected.to eq(true) }
      end

      context "matching variable" do
        let(:program) { '(begin (define str "my secret string") (equal? str "my secret string"))' }
        it { is_expected.to eq(true) }
      end

      context "mis-matching variable" do
        let(:program) { '(begin (define str "my secret string") (equal? str "public string"))' }
        it { is_expected.to eq(false) }
      end

      context "same symbols" do
        let(:program)  { "(equal? 'a 'a)" }
        it { is_expected.to eq(true) }
      end

      context "two lists, same values" do
        let(:program)  { "(equal? '(a) '(a))" }
        it { is_expected.to eq(true) }
      end

      context "two lists, same values" do
        let(:program)  { "(equal? '(a (b) c) '(a (b) c))" }
        it { is_expected.to eq(true) }
      end

      context  "same integers" do
        let(:program)  { "(equal? 2 2)" }
        it { is_expected.to eq(true) }
      end

      context  "same number, different types" do
        let(:program)  { "(equal? 2 2.0)" }
        it { is_expected.to eq(true) }
      end
    end

    context "positive?" do
      context "0" do
        let(:program) { "(positive? 0)" }
        it { is_expected.to eq(false) }
      end

      context "0.1" do
        let(:program) { "(positive? 0.1)" }
        it { is_expected.to eq(true) }
      end

      context "-10" do
        let(:program) { "(positive? -10)" }
        it { is_expected.to eq(false) }
      end

      context "given a list" do
        let(:program) { "(positive? '(1))" }
        it { expect { subject }.to raise_error }
      end
    end

    context "negative?" do
      context "0" do
        let(:program) { "(negative? 0)" }
        it { is_expected.to eq(false) }
      end

      context "10" do
        let(:program) { "(negative? 10)" }
        it { is_expected.to eq(false) }
      end

      context "-0.1" do
        let(:program) { "(negative? -0.1)" }
        it { is_expected.to eq(true) }
      end
    end
  end

  context "define" do
    context "define from env" do
      context "returns val from env" do
        let(:program) do
          """(begin
            (define x (list  'a 'b 'c))
            (define y x)
            (display y))"""
        end

        it { is_expected.to eq([:a, :b, :c]) }
      end

      context "return val is first class" do
        let(:program) do
          """(begin
            (define x (list  'a 'b 'c))
            (define y x)
            (list? y))"""
        end

        it { is_expected.to eq(true) }
      end
    end
  end

  context "pair?" do
    context "list" do
      let(:program) { "(pair? '(a b c))" }
      it {  is_expected.to eq(true) }
    end

    context "empty list" do
      let(:program) { "(pair? '())" }
      it { is_expected.to eq(false) }
    end

    context "string" do
      let(:program) { "(pair? \"ab\")" }
      it { is_expected.to eq(false) }
    end

    context "string" do
      let(:program) { "(pair? '#(a b))" }
      #it { is_expected.to eq(false) }
      it "fails" do
        expect { subject }.to raise_error
      end
    end
  end

  context "operators without arguments" do
  end

  context "nested functions" do
    let(:program) { "(/ (+ 10 10) 5)" }
    it "handles nested functions" do
      expect(subject).to eq(4)
    end
  end

  context "built-ins" do
    context "min" do
      let(:program) { "(min 5 4 2)" }
      it "computes min" do
        expect(subject).to eq(2)
      end
    end

    context "max" do
      let(:program) { "(max 5 4 2)" }
      it "computes max" do
        expect(subject).to eq(5)
      end
    end

    context "apply" do
      let(:program) { "(apply + (quote (1 2 3)))" }
      it "apply addition" do
        expect(subject).to eq(6)
      end
    end

    context "begin" do
      let(:program) do
        """(begin
             (define square (lambda (x) (* x x)))
             (square 5))"""
      end

      it "begins blocks" do
        expect(subject).to eq(25)
      end
    end

    context "cons" do
      let(:program) do
        """(begin
             (define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b)))))
             (range 0 5))"""
      end

      it "generates range" do
        expect(subject).to eq([0, 1, 2, 3, 4])
      end
    end

    context "list" do
      let(:program) do
        """(begin
             (define count (lambda (item L)
               (if (pair? L)
                 (length (filter (lambda (x) (eq? item x)) L))
                 0)))
               (count 0 (list 0 1 2 3 0 0)))"""
      end

      it "counts items in lists" do
        expect(subject).to eq(3)
      end
    end

    context "append" do
      let(:program) { "(append (quote (1 2 3)) (quote (4 5 6)) (quote (7 8 9)))" }

      it "appends" do
        expect(subject).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
      end
    end

    context "single quote" do
      context "append" do
        let(:program) { "(append '(1 2 3) '(4 5 6) '(7 8 9))" }

        it "appends" do
          expect(subject).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
        end
      end

      context "nested quote" do
        context "nested symbol" do
          let(:program) { "(display '(you can 'me))" }

          it "quotes" do
            expect(subject).to eq([:you, :can, [:quote, :me]])
          end
        end

        context "nested string" do
          let(:program) { "(display '(you can '\"Guy Steele\"))" }

          it "quotes" do
            expect(subject).to eq([:you, :can, [:quote, "Guy Steele"]])
          end
        end

        context "nested number" do
          let(:program) { "(display '(you can '44))" }

          it "quotes" do
            expect(subject).to eq([:you, :can, [:quote, 44]])
          end
        end
      end

      context "inside double quotes" do
        let(:str) { "I'm feeling lucky." }
        let(:program) { "(display \"#{str}\")" }

        it "does nothing" do
          expect(subject).to eq(str)
        end
      end
    end

    context "sqrt" do
      let(:program) { "(sqrt 16)" }
      it "calculates square root" do
        expect(subject).to eq(4)
      end
    end

    context "cos" do
      let(:program) { "(cos 0)" }
      it "calculates cos(0)" do
        expect(subject).to eq(1.0)
      end
    end

    context "sin" do
      let(:program) { "(sin 0)" }
      it "calculates sin(0)" do
        expect(subject).to eq(0.0)
      end
    end
  end

  context "booleans" do
    context "true" do
      let(:program) { "(eq? #t (> 1 0))" }
      it "casts #t to T" do
        expect(subject).to eq(true)
      end
    end

    context "false" do
      let(:program) { "(eq? #f (> 0 0))" }
      it "casts #f to F" do
        expect(subject).to eq(true)
      end
    end

    context "compare" do
      context "mismatch" do
        let(:program) { "(eq? #t (eq? #t #f))" }
        it "evaluates correct truth table" do
          expect(subject).to eq(false)
        end
      end

      context "match" do
        let(:program) { "(eq? #f (eq? #t #f))" }
        it "evaluates correct truth table" do
          expect(subject).to eq(true)
        end
      end
    end
  end

  context "strings" do
    context "extra whitespace" do
      let(:str) { "Check     this space." }
      let(:program) { "(display \"#{str}\")" }
      it "does not strip whitespace within strings" do
        expect(subject).to eq(str)
      end
    end

    context "nested parens" do
      let(:program) { "(display \"(+ 1 (2))\")" }
      it "does not add space" do
        expect(subject).to eq("(+ 1 (2))")
      end
    end

    context "nested semi-colon" do
      let(:program) { "(display \"; break\")" }
      it "does not drop" do
        expect(subject).to eq("; break")
      end
    end
  end

  context "comments" do
    let(:program) do
      """(begin ; begins a progragm
        (+ 1 2))"""
    end

    it "executes without problem" do
      expect(subject).to eq(3)
    end
  end

  context "control flow" do
    let(:program) { "((if #f + *) 3 4)" }
    it "flows correctly" do
      expect(subject).to eq(12)
    end
  end

  context "type system" do
    context "list?" do
      context "given list" do
        let(:program) { "(list? (quote (1 2 3)))" }
        it "returns true" do
          expect(subject).to eq(true)
        end
      end

      context "given non-list" do
        let(:program) { '(list? "TEST")' }
        it "returns false" do
          expect(subject).to eq(false)
        end
      end
    end
  end

  context "higher-order functions" do
    context "map" do
      let(:program) do
        """(begin
             (define map-fun (lambda (x) (+ x 1)))
             (map map-fun (quote (1 2 3))))"""
      end

      it "maps" do
        expect(subject).to eq([2, 3, 4])
      end
    end
  end

  context "persists state" do
    let(:program) { "(define square (lambda (x) (* x x)))" }
    it "persists lambdas" do
      scheme_eval(parse(program))
      resp2 = scheme_eval(parse("(square 5)"))
      expect(resp2).to eq(25)
    end
  end
end
