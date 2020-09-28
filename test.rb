require_relative "scheme"

$orig_env = $global_environment.dup
describe "scheme" do
  before(:each) do
    $global_environment = $orig_env.dup
  end

  subject { scheme_eval(parse(program)) }

  context "arithmetic" do
    context "addition" do
      context "integers" do
        let(:program) { "(+ 1 2)" }

        it "adds integers" do
          expect(subject).to eq(3)
        end
      end

      context "mixed numbers" do
        let(:program) { "(+ 1.5 2 -8)" }

        it "adds mixed numbers" do
          expect(subject).to eq(-4.5)
        end
      end
    end

    context "expt" do
      let(:program) { "(expt 2 8)" }

      it "powers numbers" do
        expect(subject).to eq(256)
      end
    end

    context "division" do
      context "/" do
        let(:program) { "(/ 5  2)" }

        it "performs true division" do
          expect(subject).to eq(2.5)
        end
      end

      context "quotient" do
        let(:program) { "(quotient 5 2)" }

        it "performs integer division" do
          expect(subject).to eq(2)
        end
      end

      context "remainders" do
        context  "modulo" do
          context "positive numbers" do
            let(:program) { "(modulo 7 3)" }
            it "calculates positve modulo" do
              expect(subject).to eq(1)
            end
          end

          context "negative numbers" do
            let(:program) { "(modulo -7 3)" }
            it "calculates negative modulo" do
              expect(subject).to eq(2)
            end
          end
        end

        context  "remainder" do
          context "positive numbers" do
            let(:program) { "(remainder 7 3)" }
            it "calculates positive remainder" do
              expect(subject).to eq(1)
            end
          end

          context "negative numbers" do
            let(:program) { "(remainder -7 3)" }
            it "calculates negative remainder" do
              expect(subject).to eq(-1)
            end
          end
        end
      end
    end
  end

  context "basic operators" do
    context "equality" do
      context ".eq?" do
        context "different types" do
          let(:program) { "(eq? 5 5.0)" }
          it "are not equal" do
            expect(subject).to eq(false)
          end
        end

        context "same types" do
          let(:program) { "(eq? 5.0 5.0)" }
          it "are equal" do
            expect(subject).to eq(true)
          end
        end

        context "different lists" do
          let(:program) { "(eq? (quote (1 2 3)) (quote (1 2 3)))" }
          it "are not equal" do
            expect(subject).to eq(false)
          end
        end

        context "same list" do
          let(:program) do
            """(begin
                 (define x (quote (1 2 3)))
                 (eq? x x))"""
          end

          it "is euqal" do
            expect(subject).to eq(true)
          end
        end
      end

      context "=" do
        context "different types" do
          let(:program) { "(= 5 5.0)" }
          it "are equal" do
            expect(subject).to eq(true)
          end
        end

        context "same types" do
          let(:program) { "(= 5 5)" }
          it "are equal" do
            expect(subject).to eq(true)
          end
        end

        context "different values" do
          let(:program) { "(= 5 6)" }
          it "are equal" do
            expect(subject).to eq(false)
          end
        end
      end
    end
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
      context(:append) do
        let(:program) { "(append (quote (1 2 3)) (quote (4 5 6)) (quote (7 8 9)))" }

        it "appends" do
          expect(subject).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
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
    context "equality" do
      let(:program) { '(equal? "test string" "test string")' }
      it "sets strings to variables" do
        expect(subject).to eq(true)
      end
    end

    context "matching variable" do
      let(:program) { '(begin (define str "my secret string") (equal? str "my secret string"))' }
      it "returns string variable" do
         expect(subject).to eq(true)
      end
    end

    context "mis-matching variable" do
      let(:program) { '(begin (define str "my secret string") (equal? str "public string"))' }
      it "returns string variable" do
         expect(subject).to eq(false)
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
