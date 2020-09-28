require_relative "scheme"

$orig_env = $global_environment.dup
describe "scheme" do
  before(:each) do
    $global_environment = $orig_env.dup
  end

  let(:resp) { scheme_eval(parse(program)) }

  context "basic math" do

    context "addition" do
      context "integers" do
        let(:program) { "(+ 1 2)" }

        it "adds integers" do
          expect(resp).to eq(3)
        end
      end

      context "mixed numbers" do
        let(:program) { "(+ 1.5 2)" }

        it "adds mixed numbers" do
          expect(resp).to eq(3.5)
        end
      end
    end
  end

  context "nested functions" do
    let(:program) { "(/ (+ 10 10) 5)" }
    it "handles nested functions" do
      expect(resp).to eq(4)
    end
  end

  context "built-ins" do
    context "min" do
      let(:program) { "(min 5 4 2)" }
      it "computes min" do
        expect(resp).to eq(2)
      end
    end

    context "max" do
      let(:program) { "(max 5 4 2)" }
      it "computes max" do
        expect(resp).to eq(5)
      end
    end

    context "apply" do
      let(:program) { "(apply + (quote (1 2 3)))" }
      it "apply addition" do
        expect(resp).to eq(6)
      end
    end

    context "begin" do
      let(:program) do
        "(begin " +
        " (define square (lambda (x) (* x x)))" +
        " (square 5))"
      end

      it "begins blocks" do
        expect(resp).to eq(25)
      end
    end

    context "cons" do
      let(:program) do
        "(begin " +
        "  (define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b)))))" +
        "  (range 0 5))"
      end

      it "generates range" do
        expect(resp).to eq([0, 1, 2, 3, 4])
      end
    end

    context "list" do
      let(:program) do
        "(begin " +
        "  (define count (lambda (item L) (if L (+ (equal? item (car L)) (count item (cdr L))) 0)))" +
        "  (count 0 (list 0 1 2 3 0 0)))"
      end

      it "counts items in lists" do
        expect(resp).to eq(3)
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
